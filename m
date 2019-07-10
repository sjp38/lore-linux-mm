Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3DAC8C73C77
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 06:24:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5AA820693
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 06:24:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="WWwMViM+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5AA820693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64AF08E006A; Wed, 10 Jul 2019 02:24:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FB5B8E0032; Wed, 10 Jul 2019 02:24:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E9968E006A; Wed, 10 Jul 2019 02:24:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 194488E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 02:24:31 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id a20so750532pfn.19
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 23:24:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mail-followup-to:mime-version:content-disposition
         :user-agent;
        bh=AJvGfeCWShvzAcCOAt+ITtSayTACBe8M0cRYIqI8UYc=;
        b=j9yz7Sg8BuCWxwmUFwtYAU9yKjc15AmiH9RgqagGUxIJtecE5mBTGPzfm65WW+XVJS
         Tf1ZgH8Za0mINv4EInQefwPnUpSOO2WlZ60Yu0ZetfRINpMxETt6Kwzfm8sBUsBjJao5
         dYkeg7wOPJX+L6srDSTcPq1A0fkf64t67tyrFM3/awWv6DoXqCAJqepDnyWP/sIZUYSq
         gl2YD6C2lWwvkgxQD9JGPQUBCHd6SMKanyjHAA+7fsh5boztgMB7kIuX6NRPupL3sgDj
         N054V171igCcTqVE2uwn3svw8DGFAI0wwEXTh+CqJCL/ksC0F+xQU0Cra2qNf2FFk1jb
         D7Jg==
X-Gm-Message-State: APjAAAWbDl1CrR4xyQ/lRgqpkG4+Md58jsTfmwfk/3341OV72++I1urT
	cMpjom4/AMQ0ChThGZpNcRl0jMjf8y2OL+N5F8AJxInm/+tbUCXT3UNPBBSBJvBb1/FobtpFj+F
	47IA2uk8k2sBsgl5gKYBWoASE4Xc7WIssog2agtniG3llCsKFiLvVTd7U8McxUg8YPw==
X-Received: by 2002:a17:902:112c:: with SMTP id d41mr36438977pla.33.1562739870458;
        Tue, 09 Jul 2019 23:24:30 -0700 (PDT)
X-Received: by 2002:a17:902:112c:: with SMTP id d41mr36436469pla.33.1562739839354;
        Tue, 09 Jul 2019 23:23:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzXxBVvlsH1b65wEr7Ujs0S0HxFuRJKhV+xHiJwAbe+5zttoENFgrSefmP+fz0R+Uppgr6Q
X-Received: by 2002:a17:902:112c:: with SMTP id d41mr36436394pla.33.1562739838405;
        Tue, 09 Jul 2019 23:23:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562739838; cv=none;
        d=google.com; s=arc-20160816;
        b=LiYboDF8vrXhXcfQrh2TPsnw2t2kzXyDtGe+U1Z05T0jVpm8Q8i2kUTenfmpu1aHeF
         aR3eH+Rm9kdygvYkEKmCHsEFBsxSrOY8v1escjhttSu180/ALtoYHT5xnCg+4GC2+z4m
         kyKm9LWt24tGr0lgDdx0VN5ekRmS3dIW6DYii4VyUIMYZGXyy87+z6nqjOGcYUqK/Meg
         IyzOLU8rp8UvgLMPL6GlJN0LQitp+/GOz3etSeVDwUyZ7d1rP6jbPrUenWb3ptyKKjkd
         owyEOiuqi1t5cG/Kceb9H75HCC7NvlnrcsOapgOE+l/38DIfMtqjpwRy0ZNYtMdsk3+x
         z6Vg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:mail-followup-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=AJvGfeCWShvzAcCOAt+ITtSayTACBe8M0cRYIqI8UYc=;
        b=F6hvCGraGO1eZgIWUJI/2ondw6pjJupJ2I3uIqkM7SkzKUtU3zzGeQnyI9IpkW6sYv
         9ghBl84m+fksyQDQ5s0NX95RAjQ2cVFM/EwxIKXwb8eC2WzehCLRVfdAsEUXl/5vNGP9
         dfWuBn/qf+K9TD+83D3mSH9ftaRa4RRmw9W2eql3X4BABhgpytgKitGxS89YJCjgw2e9
         3U9ZDKuPZqE1cmsxMbIAH/nM19/I+is4f2eAkwKxbSxftkBhCh1Z3DEPP3iknJJtgdfK
         ptlyyxhZRUdWAgv50A4pL4/tcVQGG9AKgYEXXSKCTB39Xf0rsFpRDkG/L9/kZb25/526
         6CrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=WWwMViM+;
       spf=pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=ebiggers@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w1si1286284pll.257.2019.07.09.23.23.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jul 2019 23:23:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=WWwMViM+;
       spf=pass (google.com: domain of ebiggers@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=ebiggers@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sol.localdomain (c-24-5-143-220.hsd1.ca.comcast.net [24.5.143.220])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E9B362083D;
	Wed, 10 Jul 2019 06:23:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562739838;
	bh=JTGns6p7OAqlz2mMPRTsjr8VGWN/afiuC92QNMdncxo=;
	h=Date:From:To:Cc:Subject:From;
	b=WWwMViM+9962VnK387VtomtsQHL6wHHyVkGs6um8Jpkor6A2F0toZ/nOsyEbj6MZj
	 C+bq+cyuFXRbN/qYl8RkXN38cjbzufM5pgR8+j3AKNvVcBmmdVf+JzhXVd/vxGprt1
	 YoZSs0+RnrntJuTVdW+c4AOeM8JDjfsWNDeMnPsI=
Date: Tue, 9 Jul 2019 23:23:56 -0700
From: Eric Biggers <ebiggers@kernel.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, syzkaller-bugs@googlegroups.com
Subject: Reminder: 6 open syzbot bugs in mm subsystem
Message-ID: <20190710062356.GD2152@sol.localdomain>
Mail-Followup-To: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	syzkaller-bugs@googlegroups.com
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[This email was generated by a script.  Let me know if you have any suggestions
 to make it better, or if you want it re-generated with the latest status.

 Note: currently the mm bugs look hard to do anything with and most look
 outdated, but I figured I'd send them out just in case someone has any ideas...]

Of the currently open syzbot reports against the upstream kernel, I've manually
marked 6 of them as possibly being bugs in the mm subsystem.  I've listed these
reports below, sorted by an algorithm that tries to list first the reports most
likely to be still valid, important, and actionable.

If you believe a bug is no longer valid, please close the syzbot report by
sending a '#syz fix', '#syz dup', or '#syz invalid' command in reply to the
original thread, as explained at https://goo.gl/tpsmEJ#status

If you believe I misattributed a bug to the mm subsystem, please let me know,
and if possible forward the report to the correct people or mailing list.

Here are the bugs:

--------------------------------------------------------------------------------
Title:              kernel BUG at mm/huge_memory.c:LINE!
Last occurred:      17 days ago
Reported:           187 days ago
Branches:           Mainline and others
Dashboard link:     https://syzkaller.appspot.com/bug?id=ce0353d7d140e57d81b6f1cb9252a76e50454955
Original thread:    https://lkml.kernel.org/lkml/0000000000004d2e19057e8b6d78@google.com/T/#u

Unfortunately, this bug does not have a reproducer.

The original thread for this bug received 3 replies; the last was 154 days ago.

If you fix this bug, please add the following tag to the commit:
    Reported-by: syzbot+8e075128f7db8555391a@syzkaller.appspotmail.com

If you send any email or patch for this bug, please consider replying to the
original thread.  For the git send-email command to use, or tips on how to reply
if the thread isn't in your mailbox, see the "Reply instructions" at
https://lkml.kernel.org/r/0000000000004d2e19057e8b6d78@google.com

--------------------------------------------------------------------------------
Title:              KASAN: use-after-free Read in shmem_fault
Last occurred:      77 days ago
Reported:           143 days ago
Branches:           Mainline and others
Dashboard link:     https://syzkaller.appspot.com/bug?id=53e0b9f6b68687a4c24339c7a9713c26055d4f63
Original thread:    https://lkml.kernel.org/lkml/00000000000045d4f10581fe59a7@google.com/T/#u

Unfortunately, this bug does not have a reproducer.

No one replied to the original thread for this bug.

If you fix this bug, please add the following tag to the commit:
    Reported-by: syzbot+56fbe62f8c55f860fd99@syzkaller.appspotmail.com

If you send any email or patch for this bug, please consider replying to the
original thread.  For the git send-email command to use, or tips on how to reply
if the thread isn't in your mailbox, see the "Reply instructions" at
https://lkml.kernel.org/r/00000000000045d4f10581fe59a7@google.com

--------------------------------------------------------------------------------
Title:              WARNING in untrack_pfn
Last occurred:      153 days ago
Reported:           351 days ago
Branches:           Mainline and others
Dashboard link:     https://syzkaller.appspot.com/bug?id=149d7751733001d683eca36df500722bff6cc350
Original thread:    https://lkml.kernel.org/lkml/000000000000f70a0e0571ad8ffb@google.com/T/#u

This bug has a syzkaller reproducer only.

syzbot has bisected this bug, but I think the bisection result is incorrect.

The original thread for this bug received 3 replies; the last was 62 days ago.

If you fix this bug, please add the following tag to the commit:
    Reported-by: syzbot+e1a4f80c370d2381e49f@syzkaller.appspotmail.com

If you send any email or patch for this bug, please consider replying to the
original thread.  For the git send-email command to use, or tips on how to reply
if the thread isn't in your mailbox, see the "Reply instructions" at
https://lkml.kernel.org/r/000000000000f70a0e0571ad8ffb@google.com

--------------------------------------------------------------------------------
Title:              WARNING: locking bug in split_huge_page_to_list
Last occurred:      82 days ago
Reported:           77 days ago
Branches:           Mainline
Dashboard link:     https://syzkaller.appspot.com/bug?id=867f27bec5181128ff0b1729bde7eed6786ec6bc
Original thread:    https://lkml.kernel.org/lkml/0000000000003c9bea058734dc28@google.com/T/#u

Unfortunately, this bug does not have a reproducer.

The original thread for this bug has received 1 reply, 77 days ago.

If you fix this bug, please add the following tag to the commit:
    Reported-by: syzbot+35a50f1f6dfd5a0d7378@syzkaller.appspotmail.com

If you send any email or patch for this bug, please consider replying to the
original thread.  For the git send-email command to use, or tips on how to reply
if the thread isn't in your mailbox, see the "Reply instructions" at
https://lkml.kernel.org/r/0000000000003c9bea058734dc28@google.com

--------------------------------------------------------------------------------
Title:              kernel BUG at mm/page_alloc.c:LINE!
Last occurred:      94 days ago
Reported:           174 days ago
Branches:           Mainline and others
Dashboard link:     https://syzkaller.appspot.com/bug?id=858f3346ce928ea82fba5e952e44b7c2758a3609
Original thread:    https://lkml.kernel.org/lkml/000000000000cdc61b057f9e360e@google.com/T/#u

Unfortunately, this bug does not have a reproducer.

The original thread for this bug received 3 replies; the last was 173 days ago.

If you fix this bug, please add the following tag to the commit:
    Reported-by: syzbot+80dd4798c16c634daf15@syzkaller.appspotmail.com

If you send any email or patch for this bug, please consider replying to the
original thread.  For the git send-email command to use, or tips on how to reply
if the thread isn't in your mailbox, see the "Reply instructions" at
https://lkml.kernel.org/r/000000000000cdc61b057f9e360e@google.com

--------------------------------------------------------------------------------
Title:              kernel BUG at mm/internal.h:LINE!
Last occurred:      108 days ago
Reported:           106 days ago
Branches:           Mainline and others
Dashboard link:     https://syzkaller.appspot.com/bug?id=ffde950cd7002300185185998616192428c11981
Original thread:    https://lkml.kernel.org/lkml/0000000000007311ca0584e690c1@google.com/T/#u

Unfortunately, this bug does not have a reproducer.

No one replied to the original thread for this bug.

If you fix this bug, please add the following tag to the commit:
    Reported-by: syzbot+ce4fa49466985039fb35@syzkaller.appspotmail.com

If you send any email or patch for this bug, please consider replying to the
original thread.  For the git send-email command to use, or tips on how to reply
if the thread isn't in your mailbox, see the "Reply instructions" at
https://lkml.kernel.org/r/0000000000007311ca0584e690c1@google.com

