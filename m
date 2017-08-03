Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C10256B06B9
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 09:16:04 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id d5so12946846pfg.3
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 06:16:04 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id i9si22829029plk.36.2017.08.03.06.16.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Aug 2017 06:16:03 -0700 (PDT)
Message-ID: <598322B6.8090204@intel.com>
Date: Thu, 03 Aug 2017 21:18:46 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH RESEND] mm: don't zero ballooned pages
References: <1501761557-9758-1-git-send-email-wei.w.wang@intel.com> <20170803125409.GT12521@dhcp22.suse.cz>
In-Reply-To: <20170803125409.GT12521@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, mst@redhat.com, zhenwei.pi@youruncloud.com, akpm@linux-foundation.org, dave.hansen@intel.com, mawilcox@microsoft.com

On 08/03/2017 08:54 PM, Michal Hocko wrote:
> On Thu 03-08-17 19:59:17, Wei Wang wrote:
>> This patch is a revert of 'commit bb01b64cfab7 ("mm/balloon_compaction.c:
>> enqueue zero page to balloon device")'
>>
>> Ballooned pages will be marked as MADV_DONTNEED by the hypervisor and
>> shouldn't be given to the host ksmd to scan.
> I find MADV_DONTNEED reference still quite confusing. What do you think
> about the following wording instead:
> "
> Zeroying ballon pages is rather time consuming, especially when a lot of
> pages are in flight. E.g. 7GB worth of ballooned memory takes 2.8s with
> __GFP_ZERO while it takes ~491ms without it. The original commit argued
> that zeroying will help ksmd to merge these pages on the host but this
> argument is assuming that the host actually marks balloon pages for ksm
> which is not universally true. So we pay performance penalty for
> something that even might not be used in the end which is wrong. The
> host can zero out pages on its own when there is a need.
> "

I think it looks good. Thanks.


>> Therefore, it is not
>> necessary to zero ballooned pages, which is very time consuming when
>> the page amount is large. The ongoing fast balloon tests show that the
>> time to balloon 7G pages is increased from ~491ms to 2.8 seconds with
>> __GFP_ZERO added. So, this patch removes the flag.
> The only reason why unconditional zeroying makes some sense is the
> data leak protection (guest doesn't want to leak potentially sensitive
> data to a malicious guest). I am not sure such a thread applies here
> though.


I think the unwashed contents left in the balloon pages (also free pages)
should be treated non-confidential - if the guest application has
confidential content in its memory, the application itself should zero that
before giving back that memory to the guest kernel.


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
