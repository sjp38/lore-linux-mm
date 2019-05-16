Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90B00C04AAF
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 14:20:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 504D42082E
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 14:20:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 504D42082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C29866B0005; Thu, 16 May 2019 10:20:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB24F6B0006; Thu, 16 May 2019 10:20:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A54526B0007; Thu, 16 May 2019 10:20:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 55EEF6B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 10:20:17 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id z13so1391070wrn.14
        for <linux-mm@kvack.org>; Thu, 16 May 2019 07:20:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ctvVQmdp/+3DlTEoEjBJpR8lgxdRXW/8ilCZfl4pfR8=;
        b=rN14gHJdsK4CPoGRWa2Jg0S1/jPRSzY1sCRGAwhnZKh98MHS4fHDsxoPJJVWd7okjT
         YDU5sVCuA1fcHrnzpfXReXDlCAHdzO2c9hsPFjsGE9m0MSMi96SP1UDQB0peVVxNbN2V
         1RivrJneVvuVcGVWLqiuteU2p5D4hQgXxygYuyHsYE0y7+di/4086iy5Un/zH34WPlES
         P4Akc+PO4A0n2ceu+AxwcmefDBAx2NxRjz7VF3Orokf4Vd+g5aKVH4LSD+bLv0bmP8of
         iCcXFfeotYimdvxRJJFijpjCNxi876q1r/OjFUmmAma+x0XG0Bij+P7opgbkz/Af4e1b
         G8Yw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUUaUt3XiD7S82/YcCnVxo8vzhT3v4RMCtmSOvFRmPdPqGhIJVk
	QH5J8KZl8ry1FK0KCTutalHcDG/UtEhebQWGTaMPeQ6hf+PUUeWkfFlrjHKVACNrDsuUQ/PqLlk
	I/sr8cPaElCZ5D9wJvMmGHfwB1m8c8Saym/cffJOpEp3Qt7UiG4nfkjGufU6MBLNTrQ==
X-Received: by 2002:adf:cc8d:: with SMTP id p13mr18244625wrj.114.1558016416907;
        Thu, 16 May 2019 07:20:16 -0700 (PDT)
X-Received: by 2002:adf:cc8d:: with SMTP id p13mr18244537wrj.114.1558016415716;
        Thu, 16 May 2019 07:20:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558016415; cv=none;
        d=google.com; s=arc-20160816;
        b=vwcRok5RRPiz4s3MKHClJ4JO0Izx2ezLUU/ikeiPDsbusB+qP3nieORxmsqfhfP2lo
         P0t8z7AgLJIRcdW8mOGkOTvpqep4e0Mgi6+g/uD24tRU04/wvrBWpEavgo0nUkvSjt6S
         JFylYx3e30KTOkiiBmIPScJLp54d8imrWBO5kSPNyUbpTBME0NdcgjUlt6DcVDNarexm
         NOOnx0B24zHPuugvIvZj0IEslT0AQUDjHappaN32Z9b1pzlsfzBgomzIZ3bm4HiDXS2s
         Sd2Vd3SHUEdA0kQOmhF4zK/f/9NDfAYwnPcxN2WVBJ1i9sH2PbUAlX/2BzmjRqJdS/mC
         sFJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ctvVQmdp/+3DlTEoEjBJpR8lgxdRXW/8ilCZfl4pfR8=;
        b=g2pTJTo+vk6Y06O6ZNOzssQJFybHMK6avVwg7+WBTtmN1wJGJmHA5Hls8QHyxECYl8
         ToFz3nfUqBLhYTb5Wy8GwwfkdDtgiNSlyVrT48MOkIaaWYgTZNL4d08bhVCM5Y9fP5PR
         mUIajdVjI5GDu53zEtio/HzgAMVGoN/PO8dj679kTgzQd9sGSDZi7Mav8nSGXfN5CfN3
         zLAMueBhoo+rXuqA7rbgqzi2vK2HIpgXB/L0Tx9+rouN8GuHtydSthuRzlyUFEqxRc9R
         KPdgvimMrBQC3sVhLxtoyOZ8F51d0of0hRspBo1/yqMvfGHlccoC+oSiJ3R0LHg1uVRv
         k41g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l9sor4512374wrq.27.2019.05.16.07.20.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 07:20:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqy0dFWLfD16rJATaEZWOpkMhoKfQ9XY0KhSeaf4XlwLXJ5jVr6Y8jqArL2niVKWl9/+M+mu1Q==
X-Received: by 2002:a5d:434c:: with SMTP id u12mr5534937wrr.92.1558016415071;
        Thu, 16 May 2019 07:20:15 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id w13sm9370113wmk.0.2019.05.16.07.20.13
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 16 May 2019 07:20:13 -0700 (PDT)
Date: Thu, 16 May 2019 16:20:13 +0200
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: Jann Horn <jannh@google.com>
Cc: kernel list <linux-kernel@vger.kernel.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Hugh Dickins <hughd@google.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Greg KH <greg@kroah.com>, Suren Baghdasaryan <surenb@google.com>,
	Minchan Kim <minchan@kernel.org>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>, Linux-MM <linux-mm@kvack.org>,
	Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH RFC 4/5] mm/ksm, proc: introduce remote merge
Message-ID: <20190516142013.sf2vitmksvbkb33f@butterfly.localdomain>
References: <20190516094234.9116-1-oleksandr@redhat.com>
 <20190516094234.9116-5-oleksandr@redhat.com>
 <CAG48ez2yXw_PJXO-mS=Qw5rkLpG6zDPd0saMhhGk09-du2bpaA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG48ez2yXw_PJXO-mS=Qw5rkLpG6zDPd0saMhhGk09-du2bpaA@mail.gmail.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi.

On Thu, May 16, 2019 at 12:00:24PM +0200, Jann Horn wrote:
> On Thu, May 16, 2019 at 11:43 AM Oleksandr Natalenko
> <oleksandr@redhat.com> wrote:
> > Use previously introduced remote madvise knob to mark task's
> > anonymous memory as mergeable.
> >
> > To force merging task's VMAs, "merge" hint is used:
> >
> >    # echo merge > /proc/<pid>/madvise
> >
> > Force unmerging is done similarly:
> >
> >    # echo unmerge > /proc/<pid>/madvise
> >
> > To achieve this, previously introduced ksm_madvise_*() helpers
> > are used.
> 
> Why does this not require PTRACE_MODE_ATTACH_FSCREDS to the target
> process? Enabling KSM on another process is hazardous because it
> significantly increases the attack surface for side channels.
> 
> (Note that if you change this to require PTRACE_MODE_ATTACH_FSCREDS,
> you'll want to use mm_access() in the ->open handler and drop the mm
> in ->release. mm_access() from a ->write handler is not permitted.)

Sounds reasonable. So, something similar to what mem_open() & friends do
now:

static int madvise_open(...)
...
	struct task_struct *task = get_proc_task(inode);
...
	if (task) {
		mm = mm_access(task, PTRACE_MODE_ATTACH_FSCREDS);
		put_task_struct(task);
		if (!IS_ERR_OR_NULL(mm)) {
			mmgrab(mm);
			mmput(mm);
...

Then:

static ssize_t madvise_write(...)
...
	if (!mmget_not_zero(mm))
		goto out;

	down_write(&mm->mmap_sem);
	if (!mmget_still_valid(mm))
		goto skip_mm;
...
skip_mm:
	up_write(&mm->mmap_sem);

	mmput(mm);
out:
	return ...;

And, finally:

static int madvise_release(...)
...
		mmdrop(mm);
...

Right?

> [...]
> > @@ -2960,15 +2962,63 @@ static int proc_stack_depth(struct seq_file *m, struct pid_namespace *ns,
> >  static ssize_t madvise_write(struct file *file, const char __user *buf,
> >                 size_t count, loff_t *ppos)
> >  {
> > +       /* For now, only KSM hints are implemented */
> > +#ifdef CONFIG_KSM
> > +       char buffer[PROC_NUMBUF];
> > +       int behaviour;
> >         struct task_struct *task;
> > +       struct mm_struct *mm;
> > +       int err = 0;
> > +       struct vm_area_struct *vma;
> > +
> > +       memset(buffer, 0, sizeof(buffer));
> > +       if (count > sizeof(buffer) - 1)
> > +               count = sizeof(buffer) - 1;
> > +       if (copy_from_user(buffer, buf, count))
> > +               return -EFAULT;
> > +
> > +       if (!memcmp("merge", buffer, min(sizeof("merge")-1, count)))
> 
> This means that you also match on something like "mergeblah". Just use strcmp().

I agree. Just to make it more interesting I must say that

   /sys/kernel/mm/transparent_hugepage/enabled

uses memcmp in the very same way, and thus echoing "alwaysssss" or
"madviseeee" works perfectly there, and it was like that from the very
beginning, it seems. Should we fix it, or it became (zomg) a public API?

> > +               behaviour = MADV_MERGEABLE;
> > +       else if (!memcmp("unmerge", buffer, min(sizeof("unmerge")-1, count)))
> > +               behaviour = MADV_UNMERGEABLE;
> > +       else
> > +               return -EINVAL;
> >
> >         task = get_proc_task(file_inode(file));
> >         if (!task)
> >                 return -ESRCH;
> >
> > +       mm = get_task_mm(task);
> > +       if (!mm) {
> > +               err = -EINVAL;
> > +               goto out_put_task_struct;
> > +       }
> > +
> > +       down_write(&mm->mmap_sem);
> 
> Should a check for mmget_still_valid(mm) be inserted here? See commit
> 04f5866e41fb70690e28397487d8bd8eea7d712a.

Yeah, it seems so :/. Thanks for the pointer. I've put it into the
madvise_write snippet above.

> > +       switch (behaviour) {
> > +       case MADV_MERGEABLE:
> > +       case MADV_UNMERGEABLE:
> 
> This switch isn't actually necessary at this point, right?

Yup, but it is there to highlight a possibility of adding other, non-KSM
options. So, let it be, and I'll just re-arrange CONFIG_KSM ifdef
instead.

Thank you.

> > +               vma = mm->mmap;
> > +               while (vma) {
> > +                       if (behaviour == MADV_MERGEABLE)
> > +                               ksm_madvise_merge(vma->vm_mm, vma, &vma->vm_flags);
> > +                       else
> > +                               ksm_madvise_unmerge(vma, vma->vm_start, vma->vm_end, &vma->vm_flags);
> > +                       vma = vma->vm_next;
> > +               }
> > +               break;
> > +       }
> > +       up_write(&mm->mmap_sem);
> > +
> > +       mmput(mm);
> > +
> > +out_put_task_struct:
> >         put_task_struct(task);
> >
> > -       return count;
> > +       return err ? err : count;
> > +#else
> > +       return -EINVAL;
> > +#endif /* CONFIG_KSM */
> >  }

-- 
  Best regards,
    Oleksandr Natalenko (post-factum)
    Senior Software Maintenance Engineer

