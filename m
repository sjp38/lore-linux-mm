Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9B93C6B009E
	for <linux-mm@kvack.org>; Sat,  7 Feb 2015 03:42:25 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id z12so17673965wgg.3
        for <linux-mm@kvack.org>; Sat, 07 Feb 2015 00:42:25 -0800 (PST)
Received: from mail-wg0-x22f.google.com (mail-wg0-x22f.google.com. [2a00:1450:400c:c00::22f])
        by mx.google.com with ESMTPS id dx7si6417167wib.26.2015.02.07.00.42.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Feb 2015 00:42:24 -0800 (PST)
Received: by mail-wg0-f47.google.com with SMTP id n12so17698136wgh.6
        for <linux-mm@kvack.org>; Sat, 07 Feb 2015 00:42:23 -0800 (PST)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <CA+icZUVTVdHc3QYD1LkWn=Xt-Zz6RcXPcjL6Xbpz0FZ6rdA5CQ@mail.gmail.com>
References: <CA+icZUVTVdHc3QYD1LkWn=Xt-Zz6RcXPcjL6Xbpz0FZ6rdA5CQ@mail.gmail.com>
Date: Sat, 7 Feb 2015 09:42:23 +0100
Message-ID: <CA+icZUVt_8wquKTq=A0tE7erL5iqQ7KsVDiJg_2CXd0Fu-VkcQ@mail.gmail.com>
Subject: Re: BUG: non-zero nr_pmds on freeing mm: 1
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pat Erley <pat-lkml@erley.org>
Cc: Linux-Next <linux-next@vger.kernel.org>, kirill.shutemov@linux.intel.com, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>

On Sat, Feb 7, 2015 at 8:33 AM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
> On Sat, Feb 7, 2015 at 6:12 AM, Pat Erley <pat-lkml@erley.org> wrote:
>> I'm seeing the message in $subject on my Xen DOM0 on next-20150204 on
>> x86_64.  I haven't had time to bisect it, but have seen some discussion on
>> similar topics here recently.  I can trigger this pretty reliably by
>> watching Netflix.  At some point (minutes to hours) into it, the netflix
>> video goes black (audio keeps going, so it still thinks it's working) and
>> the error appears in dmesg.  Refreshing the page gets the video going again,
>> and it will continue playing for some indeterminate amount of time.
>>
>> Kirill, I've CC'd you as looking in the logs, you've patched a false
>> positive trigger of this very recently(patch in kernel I'm running).  Am I
>> actually hitting a problem, or is this another false positive case? Any
>> additional details that might help?
>>
>> Dmesg from system attached.
>
> [ CC some mm folks ]
>
> I have seen this, too.
>
> root# grep "BUG: non-zero nr_pmds on freeing mm:" /var/log/kern.log | wc -l
> 21
>
> Checking my logs: On next-20150203 and next-20150204.
>
> I am here not in a VM environment and cannot say what causes these messages.
>

I checked a bit the logs and commits in mm.git and linux-next.git.

[1] lists:

Kirill A. Shutemov (1): mm: do not use mm->nr_pmds on !MMU configurations

NOTE: next-20150204 has this commit, but next-20150203 not (seen the
BUG: line in both releases).

Looking at Kirill's commit...

At my 1st quick look I thought Kirill mixed mm_nr_pmds_init() in the
case of defined(__PAGETABLE_PMD_FOLDED), but I was wrong.

@@ -1440,13 +1440,15 @@ static inline int __pud_alloc(struct mm_struct
*mm, pgd_t *pgd,
...
#if defined(__PAGETABLE_PMD_FOLDED) || !defined(CONFIG_MMU)
...
static inline void mm_nr_pmds_init(struct mm_struct *mm)
{
  atomic_long_set(&mm->nr_pmds, 0);
}
...
#else
...
static inline void mm_nr_pmds_init(struct mm_struct *mm) {}
...
#endif

So, I drop my idea of reverting Kirill's commit.

Pat, not sure how often you build linux-next.
When doing a daily linux-next testing... Before bisecting I normally
checked which version of linux-next was the last good and which one
was the first bad.
I cannot say which strategy is better.
But you seem to have a reliable test with watching Netflix.

Regards,
- Sedat -

[1] http://git.kernel.org/cgit/linux/kernel/git/mhocko/mm.git/tag/?id=mmotm-2015-02-03-16-38
[2] http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/?id=e060ff1f1f00caab403bd208ffa78ed1b7ee0c4d

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
