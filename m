Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3F3DC3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 21:52:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7888E233A0
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 21:52:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=arista.com header.i=@arista.com header.b="Kv1SPhc/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7888E233A0
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D50606B02AF; Wed, 21 Aug 2019 17:52:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D008D6B02B0; Wed, 21 Aug 2019 17:52:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3F076B02B1; Wed, 21 Aug 2019 17:52:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0092.hostedemail.com [216.40.44.92])
	by kanga.kvack.org (Postfix) with ESMTP id A4EA86B02AF
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 17:52:12 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 5AD26181AC9B4
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 21:52:12 +0000 (UTC)
X-FDA: 75847783704.11.flag92_30432397e211b
X-HE-Tag: flag92_30432397e211b
X-Filterd-Recvd-Size: 6362
Received: from mail-io1-f67.google.com (mail-io1-f67.google.com [209.85.166.67])
	by imf42.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 21:52:11 +0000 (UTC)
Received: by mail-io1-f67.google.com with SMTP id z3so7830834iog.0
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:52:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=arista.com; s=googlenew;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HRZ9pkhY1h9rFQYNWqajh16OFNxR0phdkMcgzEpGGcw=;
        b=Kv1SPhc/jQyHewGWa/qstvhOKINCQgUoaSRoc9djtyA4zFJG1QctbVdKBbUrBr5yo4
         UjO1bhQN0JSJBn0OCrfG4t9uEzpvolNfmtshCP4pNeBrez4MmuWSeEmP+LicgXxtDdP+
         ehz6Zic+Agz1UxJJbdvnL9MaManoPwDPj/7dGSDDWq9RrtbYLoBFL1dojkKyaeT8P35T
         +JvnMHe7EDOBYNs57XQ4iR7hByJovStYQhpTcL/lTdUdLqE5EF9R8Vxl95UULeRZD/jn
         TAdIhjw9JrNRCgQpNpAA8oflKkfPNzk/fa9GJ52Ts8lqO/b+zUoRq1BxE+8p04dkNwnE
         nEZA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=HRZ9pkhY1h9rFQYNWqajh16OFNxR0phdkMcgzEpGGcw=;
        b=XMnO/eUKskmhHOBmfDK4646sK+8RoaNvSlox3+PqV6TkrnVHGsUnTfi9lQ5ppZPDWm
         KTmIs4m3LNGZPoHtEqkok9aYu86KUtOpJk1bi1sYAPyaV7sacEopNXZp6PEEE/64VIWj
         d+MfQMAV4hyvI9EW6bpSlgHF/PkHKbTlWLNyudHM6b4OOSq/fAeZG5Lym8cOOPwyzpN3
         4bWwOHhndqfC4/l7lHiY5HZd2NPQhR+O0z193/L47J49CDh/7DKJFllKjJLUE1jd6n8H
         A2gHyy9EXzV9/d8JuA12f/elnVaHOF91DQ7AVc1HG6z/xQOUSkSmYQW9Aqmj6+s3LLdC
         9vgA==
X-Gm-Message-State: APjAAAVAhnAIahD8PGKBFXr+Vl9Q+WjzeCEVt3rBf2Mw3NCy2DhMP2Eo
	sCVmLC84zEr9s2jVrY3fmw5QeId1BPWWt6fbq8CPSA==
X-Google-Smtp-Source: APXvYqxoLJoixZyVMPCcjGuE93lHIn4QNtcinIWMsmk4mP+zCUiw2zL5eWlWQe/sg5AejOHX8d9H2YCJWiQeInNfBOk=
X-Received: by 2002:a5e:8e0d:: with SMTP id a13mr38211482ion.28.1566424330756;
 Wed, 21 Aug 2019 14:52:10 -0700 (PDT)
MIME-Version: 1.0
References: <20190821001445.32114-1-echron@arista.com> <alpine.DEB.2.21.1908202024300.141379@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.21.1908202024300.141379@chino.kir.corp.google.com>
From: Edward Chron <echron@arista.com>
Date: Wed, 21 Aug 2019 14:51:59 -0700
Message-ID: <CAM3twVT4pwDsOFm80vTsxYE7AXdV8bFKquPS7wuKFuqMo=SvoQ@mail.gmail.com>
Subject: Re: [PATCH] mm/oom: Add oom_score_adj value to oom Killed process message
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Shakeel Butt <shakeelb@google.com>, 
	linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Ivan Delalande <colona@arista.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Good point, I can post this with your correction.

I will add your Acked-by: David Rientjes <rientjes@google.com>

I am adding your Acked-by to the revised patch as this is what Michal
asked me to do (so I assume that is what I should do).

Should I post as a separate fix again or simply post here?
I'll post here and if you prefer a fresh submission, let me know and
I'll do that.

Thank-you for reviewing this patch.

-Edward Chron
Arista Networks

On Tue, Aug 20, 2019 at 8:25 PM David Rientjes <rientjes@google.com> wrote:
>
> On Tue, 20 Aug 2019, Edward Chron wrote:
>
> > For an OOM event: print oom_score_adj value for the OOM Killed process to
> > document what the oom score adjust value was at the time the process was
> > OOM Killed. The adjustment value can be set by user code and it affects
> > the resulting oom_score so it is used to influence kill process selection.
> >
> > When eligible tasks are not printed (sysctl oom_dump_tasks = 0) printing
> > this value is the only documentation of the value for the process being
> > killed. Having this value on the Killed process message documents if a
> > miscconfiguration occurred or it can confirm that the oom_score_adj
> > value applies as expected.
> >
> > An example which illustates both misconfiguration and validation that
> > the oom_score_adj was applied as expected is:
> >
> > Aug 14 23:00:02 testserver kernel: Out of memory: Killed process 2692
> >  (systemd-udevd) total-vm:1056800kB, anon-rss:1052760kB, file-rss:4kB,
> >  shmem-rss:0kB oom_score_adj:1000
> >
> > The systemd-udevd is a critical system application that should have an
> > oom_score_adj of -1000. Here it was misconfigured to have a adjustment
> > of 1000 making it a highly favored OOM kill target process. The output
> > documents both the misconfiguration and the fact that the process
> > was correctly targeted by OOM due to the miconfiguration. Having
> > the oom_score_adj on the Killed message ensures that it is documented.
> >
> > Signed-off-by: Edward Chron <echron@arista.com>
> > Acked-by: Michal Hocko <mhocko@suse.com>
>
> Acked-by: David Rientjes <rientjes@google.com>
>
> vm.oom_dump_tasks is pretty useful, however, so it's curious why you
> haven't left it enabled :/
>
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index eda2e2a0bdc6..c781f73b6cd6 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -884,12 +884,13 @@ static void __oom_kill_process(struct task_struct *victim, const char *message)
> >        */
> >       do_send_sig_info(SIGKILL, SEND_SIG_PRIV, victim, PIDTYPE_TGID);
> >       mark_oom_victim(victim);
> > -     pr_err("%s: Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
> > +     pr_err("%s: Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB oom_score_adj:%ld\n",
> >               message, task_pid_nr(victim), victim->comm,
> >               K(victim->mm->total_vm),
> >               K(get_mm_counter(victim->mm, MM_ANONPAGES)),
> >               K(get_mm_counter(victim->mm, MM_FILEPAGES)),
> > -             K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
> > +             K(get_mm_counter(victim->mm, MM_SHMEMPAGES)),
> > +             (long)victim->signal->oom_score_adj);
> >       task_unlock(victim);
> >
> >       /*
>
> Nit: why not just use %hd and avoid the cast to long?

