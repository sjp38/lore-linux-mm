Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7FF5C76194
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 22:23:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DB3B22387
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 22:23:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="wmqoLBNE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DB3B22387
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36B426B0006; Tue, 23 Jul 2019 18:23:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31B726B0007; Tue, 23 Jul 2019 18:23:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 232BB8E0002; Tue, 23 Jul 2019 18:23:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id E21EE6B0006
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 18:23:38 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id q10so3695543pgi.9
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 15:23:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+N02cUi7yGIe7sxTOiMZqMC5Wy2BbL2t7bdVDZU+ItY=;
        b=NzjJ3dSIV45sinF1KdljsMjvLKRW30gKkrY6xB18p/G5V9BFSJrZw7/BytgD1NmtpO
         3/Co5sguTQIPu9PKRw7y7XN6xJJWgYNsr4dkihIzqVbgXr//I9YI66Z47NV0c4vVmU0x
         Hnre0brOv+yL8OLnnt4l9Hnacr7N5gWkX0vwxAMDesyTj+S1rfcTP31VO6+pb8FXmeFz
         T9HkPPWONGGjXM8PWxilj2OVEyOox6nQGKCOhV+ONvm7RNdc80yd+vvJ20lHM/zEgnyz
         UWnv9akF2DfB0tD3a3nVvDMNFzvmoTID+FDKrqTyuOAMMtbHNS0e7CE/zKKsIcdn61ZC
         vIow==
X-Gm-Message-State: APjAAAVcnCeF0FBrDa9alZmsocNtGZXa6YRwnLN6x6PUfb8o/dR+jLRN
	r3s44xnhHdeqil29xZRQQ6K0lrn+9ELSIXg10p3AC+iU6RhGaV+HGChAgjflhYycrqPiW98axFJ
	FB2jf10VmzsTnEblfr/0duKXAR25jKRgdKA90Rr2Qaw9KeGsBzftYbOWRMqwG5MdxkQ==
X-Received: by 2002:a62:cdc3:: with SMTP id o186mr8041213pfg.168.1563920618482;
        Tue, 23 Jul 2019 15:23:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzU4Pdj2svMsKwUx+JtF5U/vvmrveR9oed6cRt/AvxjmMDM4StweK91MHTsg4rP35cJZ+6c
X-Received: by 2002:a62:cdc3:: with SMTP id o186mr8041176pfg.168.1563920617828;
        Tue, 23 Jul 2019 15:23:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563920617; cv=none;
        d=google.com; s=arc-20160816;
        b=DzKcyfHc7Ai/C15nXk+8XO6Z23pfqTKDQ3eiT+VAk/N9bDFtww3s+s8MWpr0DnGrtP
         Bj0kCOOc1ndotcy1GGWtOROG4dpGGkfbCdh24XaKwxAYjOXnOKOipxF9cp5AD+WpfkD4
         XUY/HKNDpBl2gOQWaHIvGTNkD92CNimh1Vfhjm6kCNsMsLAtwXa8IkAIUz06OxEcyT2J
         nUUlaMCoRKPYwhtVZN2l4wY2DaybVrXKWjjKAPNu9zh0uXXC6XXVQOk1nfiLKQU8M+p9
         YXc/hnPv9Up3SoHlJPdOgUXE+OlYaW58pLdToIsU/ojrbuVKmFUPR3H3p9fNdAvAedCT
         rCmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=+N02cUi7yGIe7sxTOiMZqMC5Wy2BbL2t7bdVDZU+ItY=;
        b=JjGPp6GwORvZLhoEvnPTuwo/5CPIZf5u/3NHZdXp0YGIPgTeBKSEOPFCUUPvjFJ8nn
         dw6PzY3UUxfx6RLW1fOj1QomzvKi7C5rb5L2CLVukHA9/eiPOIJRhsHIkJ5icUZHf8tg
         hlj9ap6ItGIdQsK6c0fdAKqGiTgNz/WG7hqoospKUs96p3DTiXhIUlIzokH53L8tfiA9
         +8yEN7VVsxRIKG8C6UCLMPKYh6M9DuUMXVlLQb8KSdIz4mFXlU4imYwgHZkRv1Zj7s+x
         PoeO2h0qtVwR8z2RvkMBOgGsYiaoTPhfzzaGoH8JQYQt93HQwbMUtDnMlFpALCHUjNjD
         9JOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=wmqoLBNE;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a20si13948879pgm.549.2019.07.23.15.23.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 15:23:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=wmqoLBNE;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.64])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 02FCA2184B;
	Tue, 23 Jul 2019 22:23:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563920617;
	bh=uBsA8GDHuhAVNuUiMbR5RWdtNhGExXIqRYqiBQBznVM=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=wmqoLBNEU59749cAIdtDiPO8nvp7PxJQI9ewxTcc+L1Xd7lnuJv+9qwibx5sHtUan
	 RqW9eXOhlRopxUm3/OKqHcynaQp6bLqrndRcXz9mJUp66kNSAOb3fR67OaD5nAJOWF
	 /LBHk+b1AjIHOOVAj4oRNERceeD1w80KpDyBeD10=
Date: Tue, 23 Jul 2019 15:23:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: syzbot <syzbot+5134cdf021c4ed5aaa5f@syzkaller.appspotmail.com>
Cc: catalin.marinas@arm.com, davem@davemloft.net, dvyukov@google.com,
 jack@suse.com, kirill.shutemov@linux.intel.com, koct9i@gmail.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-rdma@vger.kernel.org, neilb@suse.de, netdev@vger.kernel.org,
 rds-devel@oss.oracle.com, ross.zwisler@linux.intel.com,
 santosh.shilimkar@oracle.com, syzkaller-bugs@googlegroups.com,
 torvalds@linux-foundation.org, willy@linux.intel.com
Subject: Re: memory leak in rds_send_probe
Message-Id: <20190723152336.29ed51551d8c9600bb316b52@linux-foundation.org>
In-Reply-To: <00000000000034c84a058e608d45@google.com>
References: <000000000000ad1dfe058e5b89ab@google.com>
	<00000000000034c84a058e608d45@google.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Jul 2019 15:17:00 -0700 syzbot <syzbot+5134cdf021c4ed5aaa5f@syzkaller.appspotmail.com> wrote:

> syzbot has bisected this bug to:
> 
> commit af49a63e101eb62376cc1d6bd25b97eb8c691d54
> Author: Matthew Wilcox <willy@linux.intel.com>
> Date:   Sat May 21 00:03:33 2016 +0000
> 
>      radix-tree: change naming conventions in radix_tree_shrink
> 
> bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=176528c8600000
> start commit:   c6dd78fc Merge branch 'x86-urgent-for-linus' of git://git...
> git tree:       upstream
> final crash:    https://syzkaller.appspot.com/x/report.txt?x=14e528c8600000
> console output: https://syzkaller.appspot.com/x/log.txt?x=10e528c8600000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=8de7d700ea5ac607
> dashboard link: https://syzkaller.appspot.com/bug?extid=5134cdf021c4ed5aaa5f
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=145df0c8600000
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=170001f4600000
> 
> Reported-by: syzbot+5134cdf021c4ed5aaa5f@syzkaller.appspotmail.com
> Fixes: af49a63e101e ("radix-tree: change naming conventions in  
> radix_tree_shrink")
> 
> For information about bisection process see: https://goo.gl/tpsmEJ#bisection

That's rather hard to believe.  af49a63e101eb6237 simply renames a
couple of local variables.

