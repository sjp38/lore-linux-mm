Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 902A3C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 14:42:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46456207E0
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 14:42:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="BzxKUUDw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46456207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D88AE6B0277; Thu,  6 Jun 2019 10:42:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D13196B027A; Thu,  6 Jun 2019 10:42:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C01806B027B; Thu,  6 Jun 2019 10:42:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9E2EF6B0277
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 10:42:04 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id q20so123593itq.2
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 07:42:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=yI4UXAmfk5AOoLIasiEgCZLXHqdA6sJuFFsoq27RzWo=;
        b=gUHFlZqxyZFqGCvC9nEDeGQvAASIALqUTc6PKMsOn7cfvC82owTFVKdy9XYI9YZv/q
         mx1zySqNG4UFXMjtfUj7/MJpHBzcKSlJBsfXuNABQF+Rnw1YjFtBiyFoOiOf8rP0VZNi
         HWTJDbFcPAR6mqmjkzYIcyoEycByjRFkL+fQV6PcrMkktHmWx/2qigbVfbDRVHmZ+AHK
         RB3Cpxdbh/BPsPsl3+4X6N8lcvf1cnuwzMrRy6hoBMq5lKHluXsvtMBebKihBisyhAEQ
         JXkrJc+5d3C7noc/hw6fXSC0Kni0orAn7bDtZ0ON4CSytKGqPR5yIArwbK/P4wK4vJhs
         iIag==
X-Gm-Message-State: APjAAAVODmwoEfBjoklyVhvpMpEHB/d7y09ozJdIZ9ocO8iZ99RhkIRu
	hCrkUvYnUKwsExtyM3VpIpa7EZ4AUQgrMucblccQmIaZSUsHS1JdCGwtiyyezb71FeQFjqoVR/G
	7PK+MiMm/4irm+t1/NCYDueyMurnzM8v1xY0iKyg6fyAkP/W+q/5KTNodylXa9cIbKg==
X-Received: by 2002:a6b:ca47:: with SMTP id a68mr30830383iog.227.1559832124398;
        Thu, 06 Jun 2019 07:42:04 -0700 (PDT)
X-Received: by 2002:a6b:ca47:: with SMTP id a68mr30830337iog.227.1559832123736;
        Thu, 06 Jun 2019 07:42:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559832123; cv=none;
        d=google.com; s=arc-20160816;
        b=mdlGUEy7Pid51I6QF2/9/QZTji25fWpNNiGN9Sas2AdXO38s4ea/tveddPCoQvB9sa
         gU4jTaYSKW3MUp4CphCYYefK9LLVumIIaMxuWQNjr9qtEfBPoFvFaO8miq++70SjctDJ
         6K7dUz/qgZit5EESlqFrbwt0wUHlttlZvT+N/VWW98gQaHo9LVHnx/Id87EwKZ3QM+d/
         3rDUtg2ymlIDDriqcS8n+dIRcyHVTY/7wImFbWXGedKDZ+ykUAA0aFuYNDRHlWJcru2f
         pHpDwd+Xh6D+fbqCkUCGa35jz2iZJuIZ0kS2qtO9/2+DsVWEo6V+u4kgwgJBE+grcpyi
         ljhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=yI4UXAmfk5AOoLIasiEgCZLXHqdA6sJuFFsoq27RzWo=;
        b=o6QLCljAnwXbeYzC797/uEQsiJxvrVpHkHJ0OmHMXS3B6MqONreh0QjggQ/K5k1wGr
         sPCjVOsoq0Mw+NB7XQeBPcfE8dn6lCyqfUfbH+b5VNYUG1uYYcTbmW4jvpKnOmgUn2rI
         OA1rVpiK07dImlZwZ1rbFRgkNgHfNibas65wio35KVuA4/+oq/W1NCaJ9FdeVSnbpSxB
         k3+6nZiW/e5dYSHn2/H9odU8nYAX0AJMviGY+N6uDLWmSUBlGgRXhpHLa3us0cjmmMhe
         3siVmlf3r4VvOPDU7PyUayQJYHQN1T0CX/x5RyI4XF85l8Uy0bOElJGuQa1RDxt8uF0N
         PyAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BzxKUUDw;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3sor4565228jaz.3.2019.06.06.07.42.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 07:42:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BzxKUUDw;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yI4UXAmfk5AOoLIasiEgCZLXHqdA6sJuFFsoq27RzWo=;
        b=BzxKUUDwXS3pKhUbyzh0IBg3j0CX/86s/DnYE4HvoU55W1tydocpIKG1IlQOsydUQl
         huukxirzjW7kJ+AZ+Yxqd5DF19hVyAFq9uzWoSI8V5C+pjT4SW2QTLrvxGBwqP2wEB7n
         cbu8JiiySU7SgTKKDRD+5f/zYcvoBfqSXiToVcT25u3eP8nCJO72AkALhzAALlQHhXrK
         sycPgq6obiKeGQz/suhzIERteHkTaB3Rn1bK8aCr+WQ5ykQvHoq0kT4FdEryf4zaXVoR
         YMo6HytXQhUZ65ymN1q8bNjjEfA6Cug7VlsxiTSf5PwSTjES0DxHY9CxQX5ejXLVmOqu
         dPpQ==
X-Google-Smtp-Source: APXvYqxmQaijA2Oe/JJbDNLGyx4jQv3Fek40A4Cze3ibfgIGnUz18m8n3YV+uZHidCOUbrTpckx056z4S7SSrxEKBFI=
X-Received: by 2002:a02:c7c9:: with SMTP id s9mr30323015jao.82.1559832123120;
 Thu, 06 Jun 2019 07:42:03 -0700 (PDT)
MIME-Version: 1.0
References: <0000000000004945f1058aa80556@google.com>
In-Reply-To: <0000000000004945f1058aa80556@google.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 6 Jun 2019 16:41:51 +0200
Message-ID: <CACT4Y+aK8U2UG1KjuPx-tiPuRQf-T4YyQe04v5aCdP87ejodWQ@mail.gmail.com>
Subject: Re: KASAN: slab-out-of-bounds Read in corrupted (2)
To: syzbot <syzbot+9a901acbc447313bfe3e@syzkaller.appspotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Qian Cai <cai@lca.pw>, 
	Chris von Recklinghausen <crecklin@redhat.com>, Kees Cook <keescook@chromium.org>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 6, 2019 at 3:52 PM syzbot
<syzbot+9a901acbc447313bfe3e@syzkaller.appspotmail.com> wrote:
>
> Hello,
>
> syzbot found the following crash on:
>
> HEAD commit:    156c0591 Merge tag 'linux-kselftest-5.2-rc4' of git://git...
> git tree:       upstream
> console output: https://syzkaller.appspot.com/x/log.txt?x=13512d51a00000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=60564cb52ab29d5b
> dashboard link: https://syzkaller.appspot.com/bug?extid=9a901acbc447313bfe3e
> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=11a4b01ea00000

Looks +bpf related from the repro.

> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+9a901acbc447313bfe3e@syzkaller.appspotmail.com
>
> ==================================================================
> BUG: KASAN: slab-out-of-bounds in vsnprintf+0x1727/0x19a0
> lib/vsprintf.c:2503
> Read of size 8 at addr ffff8880a91c7d00 by task syz-executor.0/9821
>
> CPU: 0 PID: 9821 Comm: syz-executor.0 Not tainted 5.2.0-rc3+ #13
> Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS
> Google 01/01/2011
> Call Trace:
>
> Allocated by task 1024:
> (stack is not available)
>
> Freed by task 2310999008:
> ------------[ cut here ]------------
> Bad or missing usercopy whitelist? Kernel memory overwrite attempt detected
> to SLAB object 'skbuff_head_cache' (offset 24, size 1)!
> WARNING: CPU: 0 PID: 9821 at mm/usercopy.c:78 usercopy_warn+0xeb/0x110
> mm/usercopy.c:78
> Kernel panic - not syncing: panic_on_warn set ...
> Shutting down cpus with NMI
> Kernel Offset: disabled
>
>
> ---
> This bug is generated by a bot. It may contain errors.
> See https://goo.gl/tpsmEJ for more information about syzbot.
> syzbot engineers can be reached at syzkaller@googlegroups.com.
>
> syzbot will keep track of this bug report. See:
> https://goo.gl/tpsmEJ#status for how to communicate with syzbot.
> syzbot can test patches for this bug, for details see:
> https://goo.gl/tpsmEJ#testing-patches
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/0000000000004945f1058aa80556%40google.com.
> For more options, visit https://groups.google.com/d/optout.

