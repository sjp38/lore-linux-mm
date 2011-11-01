Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 58EDD6B006E
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 04:42:15 -0400 (EDT)
Received: by qadc11 with SMTP id c11so7236233qad.14
        for <linux-mm@kvack.org>; Tue, 01 Nov 2011 01:42:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4EB01C8F0200001600008FAE@novprvlin0050.provo.novell.com>
References: <1320049412-12642-1-git-send-email-gjhe@suse.com>
	<1320110288.22361.190.camel@sli10-conroe>
	<4EB01C8F0200001600008FAE@novprvlin0050.provo.novell.com>
Date: Tue, 1 Nov 2011 16:42:12 +0800
Message-ID: <CANejiEVk41X-P+UyMf96jmPrJJ5-_vbubYtnQgaWXY2FLb41iw@mail.gmail.com>
Subject: Re: [PATCH][mm/memory.c]: transparent hugepage check condition missed
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guan Jun He <gjhe@suse.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

2011/11/1 Guan Jun He <gjhe@suse.com>:
>
>
>>>> On 11/1/2011 at 09:18 AM, in message <1320110288.22361.190.camel@sli10=
-conroe>,
> Shaohua Li <shaohua.li@intel.com> wrote:
>> On Mon, 2011-10-31 at 16:23 +0800, Guanjun He wrote:
>>> For the transparent hugepage module still does not support
>>> tmpfs and cache,the check condition should always be checked
>>> to make sure that it only affect the anonymous maps, the
>>> original check condition missed this, this patch is to fix this.
>>> Otherwise,the hugepage may affect the file-backed maps,
>>> then the cache for the small-size pages will be unuseful,
>>> and till now there is still no implementation for hugepage's cache.
>>>
>>> Signed-off-by: Guanjun He <gjhe@suse.com>
>>> ---
>>> =A0mm/memory.c | =A0 =A03 ++-
>>> =A01 files changed, 2 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/mm/memory.c b/mm/memory.c
>>> index a56e3ba..79b85fe 100644
>>> --- a/mm/memory.c
>>> +++ b/mm/memory.c
>>> @@ -3475,7 +3475,8 @@ int handle_mm_fault(struct mm_struct *mm, struct
>> vm_area_struct *vma,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0if (pmd_trans_huge(orig_pmd)) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (flags & FAULT_FLAG_WRITE=
 &&
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!pmd_write(orig_pmd)=
 &&
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!pmd_trans_splitting(o=
rig_pmd))
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!pmd_trans_splitting(o=
rig_pmd) &&
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0!vma->vm_ops)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return do_hu=
ge_pmd_wp_page(mm, vma, address,
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pmd, orig_pmd);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>> so if vma->vm_ops !=3D NULL, how could the pmd_trans_huge(orig_pmd) be
>> true? We never enable THP if vma->vm_ops !=3D NULL.
> acturally, pmd_trans_huge(orig_pmd) only checks the _PAGE_PSE bits,
> it's only a pagesize, not a flag to identity a hugepage.
> If I change my default pagesize to PAGE_PSE,
Not sure what pagesize means here, assume pmd entry bits.
how could you make the default 'pagesize' to PAGE_PSE?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
