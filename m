Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F325C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 17:50:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4859F20679
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 17:50:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="P0/fYNP9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4859F20679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E71008E0004; Thu, 13 Jun 2019 13:50:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1F8C8E0002; Thu, 13 Jun 2019 13:50:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D0EAE8E0004; Thu, 13 Jun 2019 13:50:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id B3DA38E0002
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:50:11 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id p34so3279143qtp.1
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:50:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=CW8Dmkt0odT79Xf4+B/xbpKgEC6daDBVeyuQmTJJES8=;
        b=W66I2iutSjegsbUcDz9izGqDTPuEBqS75g8BXJbE6wyQUQcR7oztkBBHwyEJW2DyMg
         qFuPeBmElSReHSYPI5IctgOAURY8lP745yi+VsyMFJdS39Rz19RPP2dAv28YIiGNbDgp
         DKf4NmEWV2NXjKSHOKpR/O/ja6xblvxR0aLQgT2cXW1KnO5LY7tVaA5cjuuJcmPfQK/s
         1cqnRHlKeR2Jgr8m1VPcBRHyHUOF2gQolX8QPgTglbe8NICMQn4fVYExKOizPQr3BdGl
         28PswXX4BjFHLj0pcuz9MdRWXZ3kMd3XH+S7dIl1nVofxMKXHo/2LD1M6faKGiOw7l1z
         MsAQ==
X-Gm-Message-State: APjAAAVsSjxVKtIuh1ly2/2kEJWbft9Lm3WOGh/Og03S+4cs3fXWMTcb
	x7fq7tv5+I4U2zFUwpkxWTLD8W4mI8AWbyWn+PskVutVvj7ashFjvn3nmeYXcu7dT6LQqp26o3t
	lPv1MSIqi9IYP8KA94nH/hJTw3lAH0Fo2GbOuYiNEgaahql1TcAjwZ+v3B1ZXljLBEg==
X-Received: by 2002:a37:783:: with SMTP id 125mr71793256qkh.0.1560448211167;
        Thu, 13 Jun 2019 10:50:11 -0700 (PDT)
X-Received: by 2002:a37:783:: with SMTP id 125mr71793241qkh.0.1560448210513;
        Thu, 13 Jun 2019 10:50:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560448210; cv=none;
        d=google.com; s=arc-20160816;
        b=sXdeCKNCZxvP8sRpydQgnstA/i4rcjK3VN7XCiWqQVp1DIAEJGqi/OiXVyBFh6ppN+
         QXz57owytccc8tUW97HmHfEg64mnJ/mw+3Rwo+tPLmS8MaCu+BsBdXPk37vPRXQYMMpX
         tGmLT8y0MX9Li4OMUS7y1cy0v4dlUw3JEfM5pDS6ckNH/0tfvVOq1gDL5FiWlSWUE7CJ
         o3hG0ALZmn0uXDqrs2PozNaXxNJnKxGh0g4BwYd6xK2TdlixitdYFx3jgw7NRCgPmOHE
         +4w/Av0S3iVDG39PDcZ9syVm/aTOtOscoL2dkfukdiJPTm34JUPtJRDERWaKU8ZEfapP
         7zxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=CW8Dmkt0odT79Xf4+B/xbpKgEC6daDBVeyuQmTJJES8=;
        b=o/LTPhQuEvkKPGnlb0ckeBk/HNQMpcX3IIXwD/ugPW17MhW7RGQGC83NsrrD8xWmq7
         jlCoJDsh0m0ggSSf4tjG/uwVaB/2k7y3MlAUUa485Qmf2uiZSQivLfuj3tv6s006LTgp
         kPWCphlCmWIvYXrJNxzILQ1KXCwh5iQckk4Vlm8XCpj5VaRpwev1B0Sg1dYFYRJpxv9R
         8IAyA3zMdOYl2qnkjz9wU94gFU5n/MCuoj46nvHSDKvqLz0HagZyhkogz/KRjSDrGKGe
         jZIb0snnM0LVZxYx97M2gdwnW5YnThcUhAl7px+K3jDTZXIpNlF4U7qK87k7xJNuFnoC
         weLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="P0/fYNP9";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b23sor1033264qte.55.2019.06.13.10.50.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 10:50:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="P0/fYNP9";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=CW8Dmkt0odT79Xf4+B/xbpKgEC6daDBVeyuQmTJJES8=;
        b=P0/fYNP9ZcO3+OGBpONisUzkN8/fc+iUh8W32JiaGiFfNUt4qj3hrdWOLa/2kOC2Ga
         uu/8ijXw30ur7PSRQYFk7Oe6OadCse1RRqrxDoqyNJlNajrnSqTh1ShrZ48X/c3/G4b1
         9g+0Y3ZmUyd781bC8WLIAtVBzmwUTu3co6WnZDr4CXQvlI8tMzdoMpQOhxvEQuWv/dIr
         FMHaFB6W/Smdy5NjElS5AmWr8tSHAPDVdpcJzzt7mZ8Ty3sqcvZGxCvSXRIoQ81pMrC3
         kMb0362dUdKeGvJFK+wK54XHlEHfz16TwTLECzqd5j0SbpDhpcQWqdCP3c8gebNRqYEV
         sAgw==
X-Google-Smtp-Source: APXvYqyiojsO9AL2I7FFH8QZQ3t97ZM/cVMsGf4rVJyZYQVaUkpxSashUx10y6Oje86asaNHv0rxLg==
X-Received: by 2002:aed:254c:: with SMTP id w12mr79027848qtc.127.1560448210185;
        Thu, 13 Jun 2019 10:50:10 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id c4sm137165qkd.24.2019.06.13.10.50.09
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Jun 2019 10:50:09 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hbTrV-0006NJ-8F; Thu, 13 Jun 2019 14:50:09 -0300
Date: Thu, 13 Jun 2019 14:50:09 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: "Yang, Philip" <Philip.Yang@amd.com>
Cc: "Kuehling, Felix" <Felix.Kuehling@amd.com>,
	"Deucher, Alexander" <Alexander.Deucher@amd.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>
Subject: Re: [PATCH v2 hmm 00/11] Various revisions from a locking/code review
Message-ID: <20190613175009.GG22901@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190611194858.GA27792@ziepe.ca>
 <5d3b0ae2-3662-cab2-5e6c-82912f32356a@amd.com>
 <69bb7fe9-98e7-8a49-3e0b-f639010b8991@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <69bb7fe9-98e7-8a49-3e0b-f639010b8991@amd.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 09:49:12PM +0000, Yang, Philip wrote:
> Rebase to https://github.com/jgunthorpe/linux.git hmm branch, need some 
> changes because of interface hmm_range_register change. Then run a quick 
> amdgpu_test. Test is finished, result is ok.

Great! Thanks

I'll add your Tested-by to the series

>  But there is below kernel BUG message, seems hmm_free_rcu calls
> down_write.....
> 
> [ 1171.919921] BUG: sleeping function called from invalid context at 
> /home/yangp/git/compute_staging/kernel/kernel/locking/rwsem.c:65
> [ 1171.919933] in_atomic(): 1, irqs_disabled(): 0, pid: 53, name: 
> kworker/1:1
> [ 1171.919938] 2 locks held by kworker/1:1/53:
> [ 1171.919940]  #0: 000000001c7c19d4 ((wq_completion)rcu_gp){+.+.}, at: 
> process_one_work+0x20e/0x630
> [ 1171.919951]  #1: 00000000923f2cfa 
> ((work_completion)(&sdp->work)){+.+.}, at: process_one_work+0x20e/0x630
> [ 1171.919959] CPU: 1 PID: 53 Comm: kworker/1:1 Tainted: G        W 
>     5.2.0-rc1-kfd-yangp #196
> [ 1171.919961] Hardware name: ASUS All Series/Z97-PRO(Wi-Fi ac)/USB 3.1, 
> BIOS 9001 03/07/2016
> [ 1171.919965] Workqueue: rcu_gp srcu_invoke_callbacks
> [ 1171.919968] Call Trace:
> [ 1171.919974]  dump_stack+0x67/0x9b
> [ 1171.919980]  ___might_sleep+0x149/0x230
> [ 1171.919985]  down_write+0x1c/0x70
> [ 1171.919989]  hmm_free_rcu+0x24/0x80
> [ 1171.919993]  srcu_invoke_callbacks+0xc9/0x150
> [ 1171.920000]  process_one_work+0x28e/0x630
> [ 1171.920008]  worker_thread+0x39/0x3f0
> [ 1171.920014]  ? process_one_work+0x630/0x630
> [ 1171.920017]  kthread+0x11c/0x140
> [ 1171.920021]  ? kthread_park+0x90/0x90
> [ 1171.920026]  ret_from_fork+0x24/0x30

Thank you Phillip, it seems the prior tests were not done with
lockdep..

Sigh, I will keep this with the gross pagetable_lock then. I updated
the patches on the git with this modification. I think we have covered
all the bases so I will send another V of the series to the list and
if no more comments then it will move ahead to hmm.git. Thanks to all.

diff --git a/mm/hmm.c b/mm/hmm.c
index 136c812faa2790..4c64d4c32f4825 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -49,16 +49,15 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 
 	lockdep_assert_held_exclusive(&mm->mmap_sem);
 
+	/* Abuse the page_table_lock to also protect mm->hmm. */
+	spin_lock(&mm->page_table_lock);
 	if (mm->hmm) {
-		if (kref_get_unless_zero(&mm->hmm->kref))
+		if (kref_get_unless_zero(&mm->hmm->kref)) {
+			spin_unlock(&mm->page_table_lock);
 			return mm->hmm;
-		/*
-		 * The hmm is being freed by some other CPU and is pending a
-		 * RCU grace period, but this CPU can NULL now it since we
-		 * have the mmap_sem.
-		 */
-		mm->hmm = NULL;
+		}
 	}
+	spin_unlock(&mm->page_table_lock);
 
 	hmm = kmalloc(sizeof(*hmm), GFP_KERNEL);
 	if (!hmm)
@@ -81,7 +80,14 @@ static struct hmm *hmm_get_or_create(struct mm_struct *mm)
 	}
 
 	mmgrab(hmm->mm);
+
+	/*
+	 * We hold the exclusive mmap_sem here so we know that mm->hmm is
+	 * still NULL or 0 kref, and is safe to update.
+	 */
+	spin_lock(&mm->page_table_lock);
 	mm->hmm = hmm;
+	spin_unlock(&mm->page_table_lock);
 	return hmm;
 }
 
@@ -89,10 +95,14 @@ static void hmm_free_rcu(struct rcu_head *rcu)
 {
 	struct hmm *hmm = container_of(rcu, struct hmm, rcu);
 
-	down_write(&hmm->mm->mmap_sem);
+	/*
+	 * The mm->hmm pointer is kept valid while notifier ops can be running
+	 * so they don't have to deal with a NULL mm->hmm value
+	 */
+	spin_lock(&hmm->mm->page_table_lock);
 	if (hmm->mm->hmm == hmm)
 		hmm->mm->hmm = NULL;
-	up_write(&hmm->mm->mmap_sem);
+	spin_unlock(&hmm->mm->page_table_lock);
 	mmdrop(hmm->mm);
 
 	kfree(hmm);

