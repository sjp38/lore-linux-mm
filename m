Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A235C28CC3
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 11:15:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BD3A25816
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 11:15:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BD3A25816
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B05E36B026B; Thu, 30 May 2019 07:15:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8EF46B026C; Thu, 30 May 2019 07:15:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92FF56B026D; Thu, 30 May 2019 07:15:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 63D486B026B
	for <linux-mm@kvack.org>; Thu, 30 May 2019 07:15:32 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id o98so2649540ota.11
        for <linux-mm@kvack.org>; Thu, 30 May 2019 04:15:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=D2V8Dfnqhf/2uAPffgZA9ED5mQc7FL+LLmdr7yGsO0k=;
        b=Dc46oiLodGmyJg+jWM8nz5VPoWCNI2cT4nQfLxhVRkeCRhI37/Fe0lLK1bqQExhGUD
         QPQ1B07+bL1tZam9AJXvt954BkbRwCmN8BJ/tLyPWvDoZK2yfxlf2Wi4+uJ/GfBdYvLp
         hg6u01gk6hESxGvHL2Ngur6hnWhysvNAFMRHgB0SodlqsQCXTFFbASgjFBKWC8FNMoPr
         q97OkYKeeE2TIwkvspu9AgMCBvvPDUcBLjkrXiu2lZU6TSClrE3H8/yIni+0OVeOH5S/
         QwoupV9Ld986tM+bk892C1am9wEKkSmSG6BpbBasXKHhLC94CnAEUeIUyzMf9BouUJn5
         ekiw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVQg9LHa5JChyUWQsibm+NvLKVr7ygIhmXsgSVQlsX7S13ch5Jz
	ePo8XVne2VTgBCB2TW0+dmOIBXsyTtJ2UjOD9vCzfVIe7cEktT2ICEeqD9r4DZoCBNE3ETFo9Gb
	yB3SgTRRr+B7lSeX/7rLE2bG9khP4WDtJ8OBA7DdWXSamiebmyuL8uV/5vnNbCtDY6w==
X-Received: by 2002:a9d:4b01:: with SMTP id q1mr2320541otf.30.1559214931865;
        Thu, 30 May 2019 04:15:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx1y1Grlr63VADNMztvG1cT4uShAvjNlHUDai2d0aZ2Dco6Cu7IKp0QmwYb+78dNHyQEUyR
X-Received: by 2002:a9d:4b01:: with SMTP id q1mr2320488otf.30.1559214931122;
        Thu, 30 May 2019 04:15:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559214931; cv=none;
        d=google.com; s=arc-20160816;
        b=lBpQjgBZAZ7WPux3+XnPkLdFKV1TKK73JVqN6b8niC0K0b7GvAAdVi2OdMxl957CAF
         5WnyF0S8JnV9yDaaKc/DOF7loWaqlDKlxD20vEladIoZy7KGPuqU8vcWmEQ2Q8iRUZU/
         eKFa9TpNuvykqdnXCNV4knKiFMUtvEPKPTSL+x4T9L67WFhWyle7+JHN7D7UktQfu64C
         BcEcP1/1OfTxVlXu29cA5Uas2COmoOPXh4iJ3d32h4GU9hbDzuB2PcfHMpyzpFfNxiqu
         8292R2kdrdtByjCD9UlOfv69m4BqdS4r8JLjOv74d8ffFYbRIuUA/UsJBedamVR5yPSi
         Cv1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=D2V8Dfnqhf/2uAPffgZA9ED5mQc7FL+LLmdr7yGsO0k=;
        b=c65GaKzLzceD1UImQrlYtimBxpxo2CMEFzdqdOMrd79pPYM5aCR6VQbdQIeAHJ6blI
         bde+W8hjXRuoPKSqdu6gUkTv06KdR64P+LNvuan1/9361pFNVzjB1MKxLqiOIj6awb9Y
         fdz0KjfNFV7tlbp7lSqgoH6rPqKZc2Xv2cyqXVpiQF4yZkG3bCG0blOJk/t522ZYcxsd
         nbyKDi2JnVSBVIFJPoKPecj7ClcU1M6QlpFaMZUjXoV9TFvHBLCiYbWjTk9WWdDZpXoP
         jEaKgbn/jZSKuislgUVTUh4xAefEP15LLn8rXq3ShuzaDobSzN/Bsi9GCH+3xDO/+mWM
         0+BQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l19si1255096otn.138.2019.05.30.04.15.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 04:15:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 63AEB308FF30;
	Thu, 30 May 2019 11:15:25 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.159])
	by smtp.corp.redhat.com (Postfix) with SMTP id 94F747944B;
	Thu, 30 May 2019 11:15:21 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Thu, 30 May 2019 13:15:24 +0200 (CEST)
Date: Thu, 30 May 2019 13:15:20 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Qian Cai <cai@lca.pw>
Cc: axboe@kernel.dk, akpm@linux-foundation.org, hch@lst.de,
	peterz@infradead.org, gkohli@codeaurora.org, mingo@redhat.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] block: fix a crash in do_task_dead()
Message-ID: <20190530111519.GC22536@redhat.com>
References: <1559161526-618-1-git-send-email-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1559161526-618-1-git-send-email-cai@lca.pw>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Thu, 30 May 2019 11:15:30 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 05/29, Qian Cai wrote:
>
> The commit 0619317ff8ba ("block: add polled wakeup task helper")
> replaced wake_up_process() with blk_wake_io_task() in
> end_swap_bio_read() which triggers a crash when running heavy swapping
> workloads.
> 
> [T114538] kernel BUG at kernel/sched/core.c:3462!
> [T114538] Process oom01 (pid: 114538, stack limit = 0x000000004f40e0c1)
> [T114538] Call trace:
> [T114538]  do_task_dead+0xf0/0xf8
> [T114538]  do_exit+0xd5c/0x10fc
> [T114538]  do_group_exit+0xf4/0x110
> [T114538]  get_signal+0x280/0xdd8
> [T114538]  do_notify_resume+0x720/0x968
> [T114538]  work_pending+0x8/0x10
> 
> This is because shortly after set_special_state(TASK_DEAD),
> end_swap_bio_read() is called from an interrupt handler that revive the
> task state to TASK_RUNNING causes __schedule() to return and trip the
> BUG() later.
> 
> [  C206] Call trace:
> [  C206]  dump_backtrace+0x0/0x268
> [  C206]  show_stack+0x20/0x2c
> [  C206]  dump_stack+0xb4/0x108
> [  C206]  blk_wake_io_task+0x7c/0x80
> [  C206]  end_swap_bio_read+0x22c/0x31c
> [  C206]  bio_endio+0x3d8/0x414
> [  C206]  dec_pending+0x280/0x378 [dm_mod]
> [  C206]  clone_endio+0x128/0x2ac [dm_mod]
> [  C206]  bio_endio+0x3d8/0x414
> [  C206]  blk_update_request+0x3ac/0x924
> [  C206]  scsi_end_request+0x54/0x350
> [  C206]  scsi_io_completion+0xf0/0x6f4
> [  C206]  scsi_finish_command+0x214/0x228
> [  C206]  scsi_softirq_done+0x170/0x1a4
> [  C206]  blk_done_softirq+0x100/0x194
> [  C206]  __do_softirq+0x350/0x790
> [  C206]  irq_exit+0x200/0x26c
> [  C206]  handle_IPI+0x2e8/0x514
> [  C206]  gic_handle_irq+0x224/0x228
> [  C206]  el1_irq+0xb8/0x140
> [  C206]  _raw_spin_unlock_irqrestore+0x3c/0x74
> [  C206]  do_task_dead+0x88/0xf8
> [  C206]  do_exit+0xd5c/0x10fc
> [  C206]  do_group_exit+0xf4/0x110
> [  C206]  get_signal+0x280/0xdd8
> [  C206]  do_notify_resume+0x720/0x968
> [  C206]  work_pending+0x8/0x10
> 
> Before the offensive commit, wake_up_process() will prevent this from
> happening by taking the pi_lock and bail out immediately if TASK_DEAD is
> set.
> 
> if (!(p->state & TASK_NORMAL))
> 	goto out;

I don't understand this code at all but I am just curious, can we do
something like incomplete patch below ?

Oleg.

--- x/mm/page_io.c
+++ x/mm/page_io.c
@@ -140,8 +140,10 @@ int swap_readpage(struct page *page, bool synchronous)
 	unlock_page(page);
 	WRITE_ONCE(bio->bi_private, NULL);
 	bio_put(bio);
-	blk_wake_io_task(waiter);
-	put_task_struct(waiter);
+	if (waiter) {
+		blk_wake_io_task(waiter);
+		put_task_struct(waiter);
+	}
 }
 
 int generic_swapfile_activate(struct swap_info_struct *sis,
@@ -398,11 +400,12 @@ int swap_readpage(struct page *page, boo
 	 * Keep this task valid during swap readpage because the oom killer may
 	 * attempt to access it in the page fault retry time check.
 	 */
-	get_task_struct(current);
-	bio->bi_private = current;
 	bio_set_op_attrs(bio, REQ_OP_READ, 0);
-	if (synchronous)
+	if (synchronous) {
 		bio->bi_opf |= REQ_HIPRI;
+		get_task_struct(current);
+		bio->bi_private = current;
+	}
 	count_vm_event(PSWPIN);
 	bio_get(bio);
 	qc = submit_bio(bio);

