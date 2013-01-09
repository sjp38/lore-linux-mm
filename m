Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 5029C6B004D
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 06:38:25 -0500 (EST)
Received: by mail-ob0-f182.google.com with SMTP id 16so2060072obc.27
        for <linux-mm@kvack.org>; Wed, 09 Jan 2013 03:38:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFwcDs_R0Cv=RS2LD8ggP3EdvODjENAsXNe126xNwYatOQ@mail.gmail.com>
References: <CAJd=RBCb0oheRnVCM4okVKFvKGzuLp9GpZJCkVY3RR-J=XEoBA@mail.gmail.com>
	<alpine.LNX.2.00.1301061037140.28950@eggly.anvils>
	<CAJd=RBAps4Qk9WLYbQhLkJd8d12NLV0CbjPYC6uqH_-L+Vu0VQ@mail.gmail.com>
	<CA+55aFyYAf6ztDLsxWFD+6jb++y0YNjso-9j+83Mm+3uQ=8PdA@mail.gmail.com>
	<CAJd=RBDTvCcYV8qAd-++_DOyDSypQD4Dvt216pG9nTQnWA2uCA@mail.gmail.com>
	<CA+55aFzfUABPycR82aNQhHNasQkL1kmxLN1rD0DJcByFtead3g@mail.gmail.com>
	<20130108163141.GA27555@shutemov.name>
	<CA+55aFzaTvF7nYxWBT-G_b=xGz+_akRAeJ=U9iHy+Y=ZPo=pbA@mail.gmail.com>
	<20130108173747.GF9163@redhat.com>
	<CA+55aFyG26N3_KiA8_cxLW59xFMJBK8SKfG4qL80NMQ3tdh3Nw@mail.gmail.com>
	<20130108180346.GH9163@redhat.com>
	<CA+55aFwcDs_R0Cv=RS2LD8ggP3EdvODjENAsXNe126xNwYatOQ@mail.gmail.com>
Date: Wed, 9 Jan 2013 19:38:24 +0800
Message-ID: <CAJd=RBAe5D11+L1H3_cgbcCGuCv0-oSLi_uu84f7ozG4yDO7=w@mail.gmail.com>
Subject: Re: oops in copy_page_rep()
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>

On Wed, Jan 9, 2013 at 2:21 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Tue, Jan 8, 2013 at 10:03 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
>>
>> It looks very fine to me, but I suggest to move it above the
>> pmd_numa() check because of the newly introduced
>> migrate_misplaced_transhuge_page method relying on pmd_same too.
>
> Hmm. If we need it there, then we need to fix the *later* case of
> pmd_numa() too:
>
>         if (pmd_numa(*pmd))
>                 return do_pmd_numa_page(mm, vma, address, pmd);
>
> Also, and more fundamentally, since do_pmd_numa_page() doesn't take
> the orig_pmd thing as an argument (and re-check it under the
> page-table lock), testing pmd_trans_splitting() on it is pointless,
> since it can change later.
>
A splitting pmd has to be huge first, and we do handle huge pmd already in
the up dozen of lines.
That said, we can igore splitting check in this case, Sir.

Hillf

> So no, moving the check up does *not* make sense, at least not without
> other changes. Because if I read things right, pmd_trans_splitting()
> really has to be done with the page-table lock protection (where "with
> page-table lock protection" does *not* mean that it has to be done
> under the page table lock, but if it is done outside, then the pmd
> entry has to be re-verified after getting the lock - which both
> do_huge_pmd_wp_page() and huge_pmd_set_accessed() correctly do).
>
> Comments?
>
>                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
