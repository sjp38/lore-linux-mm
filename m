Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id B02CA6B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 22:24:08 -0500 (EST)
Received: by wera13 with SMTP id a13so1117526wer.14
        for <linux-mm@kvack.org>; Fri, 13 Jan 2012 19:24:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F104A51.2000701@ah.jp.nec.com>
References: <1326396898-5579-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1326396898-5579-3-git-send-email-n-horiguchi@ah.jp.nec.com>
	<CAJd=RBB6azf9nin5tjqTtHakxy896rCxr6ErK4p2KDrke_goEA@mail.gmail.com>
	<4F104A51.2000701@ah.jp.nec.com>
Date: Sat, 14 Jan 2012 11:24:06 +0800
Message-ID: <CAJd=RBB2GMRQNUH+2z7R5Fy6OKKtid9wn2mTFORvtefo+wUaOQ@mail.gmail.com>
Subject: Re: [PATCH 2/6] thp: optimize away unnecessary page table locking
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jan 13, 2012 at 11:14 PM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> Hi Hillf,
>
> (1/13/2012 7:04), Hillf Danton wrote:
> [...]
>>> +/*
>>> + * Returns 1 if a given pmd is mapping a thp and stable (not under spl=
itting.)
>>> + * Returns 0 otherwise. Note that if it returns 1, this routine return=
s without
>>> + * unlocking page table locks. So callers must unlock them.
>>> + */
>>> +int pmd_trans_huge_stable(pmd_t *pmd, struct vm_area_struct *vma)
>>> +{
>>> + =C2=A0 =C2=A0 =C2=A0 VM_BUG_ON(!rwsem_is_locked(&vma->vm_mm->mmap_sem=
));
>>> +
>>> + =C2=A0 =C2=A0 =C2=A0 if (!pmd_trans_huge(*pmd))
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
>>> +
>>> + =C2=A0 =C2=A0 =C2=A0 spin_lock(&vma->vm_mm->page_table_lock);
>>> + =C2=A0 =C2=A0 =C2=A0 if (likely(pmd_trans_huge(*pmd))) {
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (pmd_trans_splitt=
ing(*pmd)) {
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 spin_unlock(&vma->vm_mm->page_table_lock);
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 wait_split_huge_page(vma->anon_vma, pmd);
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 return 0;
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } else {
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock(&vma->vm_mm->page_table_lock); =C2=
=A0 =C2=A0 yes?
>
> No. Unlocking is supposed to be done by the caller as commented.
>
Thanks for correcting /Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
