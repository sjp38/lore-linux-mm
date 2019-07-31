Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71F02C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:55:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E895B2089E
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 08:55:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=mailbox.org header.i=@mailbox.org header.b="MkDvlwfO";
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=mailbox.org header.i=@mailbox.org header.b="tv//Z9n0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E895B2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mailbox.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D0368E0005; Wed, 31 Jul 2019 04:55:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 880278E0001; Wed, 31 Jul 2019 04:55:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 74AE18E0005; Wed, 31 Jul 2019 04:55:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 25B398E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 04:55:17 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r21so41962938edc.6
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 01:55:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MlnBrMG1l/K17a8NWNmt9Fxa0ImKConZ5zhXCpwRVVc=;
        b=oc895jc/RUw9ld6UGPLZRwEVWn7mCv0366kTfld9sa5saRHntyOvvnF7JE7VJ5I51D
         ERahBYUXIQAJbReAblfUYOrDFME74QxErAu6N/c52HM81zrhnD0gVFc/TWGjjyLmKfnx
         fcgACjX8hzGKMX83iYKnYR+1CqKpzw/f6ErNjElKhK86fK+VoQsSkiBcjEpclti/RhhT
         z9G6y//PmtZDtWANlT1xuTZI5kC62jfJ6dc5KSbUCxHIf6ynpULK9LzFpHyrtPw4oGBb
         aPWLYbYWeNKKR2vapr0G8BJHsoWl+Nd3tEkdl/g49mQadf9tr+7u9dQhygdbrxyiIphh
         KqZA==
X-Gm-Message-State: APjAAAWPMzhGGwYSUOuD3ehkUStAC1UoAAtrEDuD7Il7bjZAov8mOwAF
	jod7Od8v2JSeCbaLgVVc9HNsQFrZHeAdO2wVNsZnd/dc54RP287r5lLbnOGmLPNri8NDfhCQp2F
	F4HUpm258iwg1MmjBLYOnnUD9JPZW9hnamvyzaIKslWHy6nFYxcoD9nP+AG7rrGgsRw==
X-Received: by 2002:a17:906:f0c7:: with SMTP id dk7mr92866891ejb.97.1564563316695;
        Wed, 31 Jul 2019 01:55:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzaBNBTJSHNTeowDB8PraxTM0Zbh7FP7B7Ngec72+P1MlImAlh7Ybt+3CbrEkbpTq2d5/2z
X-Received: by 2002:a17:906:f0c7:: with SMTP id dk7mr92866851ejb.97.1564563315844;
        Wed, 31 Jul 2019 01:55:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564563315; cv=none;
        d=google.com; s=arc-20160816;
        b=wWHzD2L+HHczxYfBd6Z59brKjqUkFqaEGRiZtU7TMoPsnYPB93cZY/2jWTphf+AjmD
         MTTVb35OaF8MrT/Ln8eYsDn27+hpl8W/LtYzynQz+NwEpzAIqUSNdgVUc+MqsW19DAt9
         RE1Rk7EJIcoD3m0HIfzPnCTxVPLYJTe4ITi6yQTES5VHgrHY2qzh05lZf0Y4Hdr7b/Sb
         2VnjFCo5JTVGrNlXiNZVjYVkf0mNYkVW/BE4COtF+TweRvjcfXGtpB2ewUWaxkkZnqz7
         dfXfFlvrNv+ZEYSGVFgg19DBG1SmLzn+Al5SheacA1w1zUAgn7vunyqQsh+tsXAmmcQU
         JYsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=MlnBrMG1l/K17a8NWNmt9Fxa0ImKConZ5zhXCpwRVVc=;
        b=lPsgflDfvUsdZBEJemAMNTBYIJPbg0GZw5g5xGbOHsP7YqBEqWpruQ1jtn3QI0g8CU
         of81OaEjIY2rUvgRtWZ3PMIguWBOTaUYHQoaVEHXchb1LRrd2jQlY19lQGSW5Qq51vbT
         wNSkp0ixZ6SZQE3Q0YyCAsdQH6zuEVvt5eNlaWWdK7joBvDR2dbesJEoNS/BpdHG3U7D
         +8C0SBONHC2IVD/f7zbqoGSDoeU0QnjrvwAtBp1htpOJp+ZNBYYugFkO7BvZ1hBAVRWM
         WJNBEX6sQ6qlH8tOgYU2rlMz02TgNt8MtvjvZA7npgdTk41VdBR3P/RexmrvJELRj1kh
         K02A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@mailbox.org header.s=mail20150812 header.b=MkDvlwfO;
       dkim=pass header.i=@mailbox.org header.s=mail20150812 header.b="tv//Z9n0";
       spf=pass (google.com: domain of erhard_f@mailbox.org designates 80.241.60.212 as permitted sender) smtp.mailfrom=erhard_f@mailbox.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mailbox.org
Received: from mx1.mailbox.org (mx1.mailbox.org. [80.241.60.212])
        by mx.google.com with ESMTPS id m7si7311956edd.122.2019.07.31.01.55.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 31 Jul 2019 01:55:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of erhard_f@mailbox.org designates 80.241.60.212 as permitted sender) client-ip=80.241.60.212;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@mailbox.org header.s=mail20150812 header.b=MkDvlwfO;
       dkim=pass header.i=@mailbox.org header.s=mail20150812 header.b="tv//Z9n0";
       spf=pass (google.com: domain of erhard_f@mailbox.org designates 80.241.60.212 as permitted sender) smtp.mailfrom=erhard_f@mailbox.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mailbox.org
Received: from smtp1.mailbox.org (smtp1.mailbox.org [IPv6:2001:67c:2050:105:465:1:1:0])
	(using TLSv1.2 with cipher ECDHE-RSA-CHACHA20-POLY1305 (256/256 bits))
	(No client certificate requested)
	by mx1.mailbox.org (Postfix) with ESMTPS id 5049450BB7;
	Wed, 31 Jul 2019 10:55:15 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=mailbox.org; h=
	content-transfer-encoding:content-type:content-type:mime-version
	:references:in-reply-to:message-id:subject:subject:from:from
	:date:date:received; s=mail20150812; t=1564563308; bh=SqrWOHm8cX
	JAAwNnUrb/RsX+K8SLIKZswEjZrRREZjk=; b=MkDvlwfOdf9coqYkwnBG65ZtHt
	dsgNP0mTYA2vPgMVnm3/IL8tbcG9xj80FsOuPr21JizbCoyhxpe4FTJLA0jeM9H0
	hRpbEy4PJYWkMqQw5K4ABvTeZ9ey5VczZlo/rZGavWdO+UiW1WRfZkxsycivBIfy
	VJFPZ37PT9n6XRyjITsHfZj7Mm6fWOBR2HIqOIpC5jXwTEyjwWXG6NDUMgO8YlYI
	a2QsIh6wrwbuYv6Ycig34juMsC2sWd0cOu3LTEe8SrCtliJJwQ8gTz4y+iiIMuze
	tjRNeMjJ4f86L8K6RdwVabWWYYh02rL4wwK85V/6HHxPnWgMVdYb8acyZBlw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=mailbox.org; s=mail20150812;
	t=1564563315; h=from:from:sender:reply-to:subject:subject:date:date:
	 message-id:message-id:to:to:cc:cc:mime-version:mime-version:
	 content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=MlnBrMG1l/K17a8NWNmt9Fxa0ImKConZ5zhXCpwRVVc=;
	b=tv//Z9n0AL5uamGwiMElFjAV2gI5J56rGYcw27avQGkSgcxyNegPknp3GhQvyLhMY3lUYC
	bsNTSXp/xHMcS5kbzM4h6n2GVP45XOgGt7e5/Ys3KByyI8O8sF0teHKNwQUWjbNCvPVIKq
	b3tutgzRei7ceCNtZVq3GyhGx5ImfBoBka16iHNMM6O5ypN0BzpcSZYaGe345zeF8xul8r
	UhPA8K/bzpf3RJ0jsv2L6lY+j3bs8ClCtCpuNLJp1ZPdcC4Lq8ABbmINc9avGEptQeNJuX
	ZE0D7gbecQqNBcHc3qO/mf/5kpfEcBRr7S36QJIXeH8j3NpBti1RE2BjfVsvhQ==
X-Virus-Scanned: amavisd-new at heinlein-support.de
Received: from smtp1.mailbox.org ([80.241.60.240])
	by hefe.heinlein-support.de (hefe.heinlein-support.de [91.198.250.172]) (amavisd-new, port 10030)
	with ESMTP id HHdkiIv5u-Wo; Wed, 31 Jul 2019 10:55:08 +0200 (CEST)
Date: Wed, 31 Jul 2019 10:54:58 +0200
From: "Erhard F." <erhard_f@mailbox.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, Daniel Borkmann
 <daniel@iogearbox.net>, Nicolas Schichan <nschichan@freebox.fr>, Alexei
 Starovoitov <ast@plumgrid.com>, Jiri Pirko <jpirko@redhat.com>,
 linux-mm@kvack.org
Subject: Re: [Bug 204371] New: BUG kmalloc-4k (Tainted: G        W        ):
 Object padding overwritten
Message-ID: <20190731105458.18803339@supah>
In-Reply-To: <20190730115244.777c3c6181722f5fb8e97c73@linux-foundation.org>
References: <bug-204371-27@https.bugzilla.kernel.org/>
	<20190730115244.777c3c6181722f5fb8e97c73@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Jul 2019 11:52:44 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> 
> On Mon, 29 Jul 2019 22:35:48 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > https://bugzilla.kernel.org/show_bug.cgi?id=204371
> > 
> >             Bug ID: 204371
> >            Summary: BUG kmalloc-4k (Tainted: G        W        ): Object
> >                     padding overwritten
> >            Product: Memory Management
> >            Version: 2.5
> >     Kernel Version: 5.3.0-rc2
> >           Hardware: PPC-32
> >                 OS: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Slab Allocator
> >           Assignee: akpm@linux-foundation.org
> >           Reporter: erhard_f@mailbox.org
> >         Regression: No  
> 
> cc'ing various people here.
> 
> I suspect proc_cgroup_show() is innocent and that perhaps
> bpf_prepare_filter() had a memory scribble.  iirc there has been at
> least one recent pretty serious bpf fix applied recently.  Can others
> please take a look?
> 
> (Seriously - please don't modify this report via the bugzilla web interface!)

Hm, don't know whether this is bpfs fault.. I am getting this for other things too:

[...]
Jul 31 10:46:53 T600 kernel: Object 442ee539: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
Jul 31 10:46:53 T600 kernel: Object 41b83bb9: 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b a5  kkkkkkkkkkkkkkk.
Jul 31 10:46:53 T600 kernel: Redzone 720e193a: bb bb bb bb                                      ....
Jul 31 10:46:53 T600 kernel: Padding 0b116c89: 00 00 00 00 00 00 00 00                          ........
Jul 31 10:46:53 T600 kernel: CPU: 1 PID: 120 Comm: systemd-journal Tainted: G    B   W         5.2.4-gentoo #1
Jul 31 10:46:53 T600 kernel: Call Trace:
Jul 31 10:46:53 T600 kernel: [dd663b68] [c0628d80] dump_stack+0xa0/0xfc (unreliable)
Jul 31 10:46:53 T600 kernel: [dd663b98] [c01984ac] check_bytes_and_report+0xc8/0xf0
Jul 31 10:46:53 T600 kernel: [dd663bc8] [c0198fd0] check_object+0x10c/0x224
Jul 31 10:46:53 T600 kernel: [dd663bf8] [c0199964] alloc_debug_processing+0xc4/0x13c
Jul 31 10:46:53 T600 kernel: [dd663c18] [c0199bc4] ___slab_alloc.constprop.72+0x1e8/0x380
Jul 31 10:46:53 T600 kernel: [dd663ca8] [c0199d9c] __slab_alloc.constprop.71+0x40/0x6c
Jul 31 10:46:53 T600 kernel: [dd663cd8] [c019a014] kmem_cache_alloc_trace+0x7c/0x170
Jul 31 10:46:53 T600 kernel: [dd663d18] [c02d6a5c] btrfs_opendir+0x48/0x78
Jul 31 10:46:53 T600 kernel: [dd663d38] [c01a9320] do_dentry_open+0x25c/0x2f0
Jul 31 10:46:53 T600 kernel: [dd663d68] [c01bc284] path_openat+0x814/0xaf0
Jul 31 10:46:53 T600 kernel: [dd663e38] [c01bc5a4] do_filp_open+0x44/0xa0
Jul 31 10:46:53 T600 kernel: [dd663ee8] [c01aa178] do_sys_open+0x7c/0x108
Jul 31 10:46:53 T600 kernel: [dd663f38] [c0015274] ret_from_syscall+0x0/0x34
Jul 31 10:46:53 T600 kernel: --- interrupt: c00 at 0x7eae14
                                 LR = 0x7eadf8
Jul 31 10:46:53 T600 kernel: FIX kmalloc-4k: Restoring 0x0b116c89-0x85f2eca1=0x5a
[...]


-- 
 PGP-ID: 0x98891295 Fingerprint: 923B 911C 9366 E229 3149 9997 8922 516C 9889 1295
riot.im: @ernsteiswuerfel:matrix.org

