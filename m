Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3F7D96B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 11:30:45 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id 83so139342944vkd.3
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 08:30:45 -0700 (PDT)
Received: from mail-vk0-x242.google.com (mail-vk0-x242.google.com. [2607:f8b0:400c:c05::242])
        by mx.google.com with ESMTPS id h1si3878517vkf.181.2016.10.17.08.30.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 08:30:44 -0700 (PDT)
Received: by mail-vk0-x242.google.com with SMTP id 2so8097903vkb.1
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 08:30:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5804C88F.7040000@huawei.com>
References: <1476331337-17253-1-git-send-email-zhongjiang@huawei.com>
 <5804305F.4030302@huawei.com> <CAMJBoFMcnH3ZPQpG=oAjD=K64O7MX_BdFvHvccvgCV4nFSfxXA@mail.gmail.com>
 <5804C88F.7040000@huawei.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Mon, 17 Oct 2016 11:30:03 -0400
Message-ID: <CALZtONC8frCrF_v1bm_+HePfLMypL7Z6DNJor8Z6NCMzeG5ERQ@mail.gmail.com>
Subject: Re: [PATCH v2] z3fold: fix the potential encode bug in encod_handle
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Vitaly Wool <vitalywool@gmail.com>, Dave Chinner <david@fromorbit.com>, Seth Jennings <sjenning@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, Oct 17, 2016 at 8:48 AM, zhong jiang <zhongjiang@huawei.com> wrote:
>
> On 2016/10/17 20:03, Vitaly Wool wrote:
> > Hi Zhong Jiang,
> >
> > On Mon, Oct 17, 2016 at 3:58 AM, zhong jiang <zhongjiang@huawei.com> wrote:
> >> Hi,  Vitaly
> >>
> >> About the following patch,  is it right?
> >>
> >> Thanks
> >> zhongjiang
> >> On 2016/10/13 12:02, zhongjiang wrote:
> >>> From: zhong jiang <zhongjiang@huawei.com>
> >>>
> >>> At present, zhdr->first_num plus bud can exceed the BUDDY_MASK
> >>> in encode_handle, it will lead to the the caller handle_to_buddy
> >>> return the error value.
> >>>
> >>> The patch fix the issue by changing the BUDDY_MASK to PAGE_MASK,
> >>> it will be consistent with handle_to_z3fold_header. At the same time,
> >>> change the BUDDY_MASK to PAGE_MASK in handle_to_buddy is better.
> > are you seeing problems with the existing code? first_num should wrap around
> > BUDDY_MASK and this should be ok because it is way bigger than the number
> > of buddies.
> >
> > ~vitaly
> >
> > .
> >
>  first_num plus buddies can exceed the BUDDY_MASK. is it right?

yes.

>
>  (first_num + buddies) & BUDDY_MASK may be a smaller value than first_num.

yes, but that doesn't matter; the value stored in the handle is never
accessed directly.

>
>   but (handle - zhdr->first_num) & BUDDY_MASK will return incorrect value
>   in handle_to_buddy.

the subtraction and masking will result in the correct buddy number,
even if (handle & BUDDY_MASK) < zhdr->first_num.

However, I agree it's nonobvious, and tying the first_num size to
NCHUNKS_ORDER is confusing - the number of chunks is completely
unrelated to the number of buddies.

Possibly a better way to handle first_num is to limit it to the order
of enum buddy to the actual range of possible buddy indexes, which is
0x3, i.e.:

#define BUDDY_MASK      (0x3)

and

       unsigned short first_num:2;

with that and a small bit of explanation in the encode_handle or
handle_to_buddy comments, it should be clear how the first_num and
buddy numbering work, including that overflow/underflow are ok (due to
the masking)...

>
>   Thanks
>   zhongjiang
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
