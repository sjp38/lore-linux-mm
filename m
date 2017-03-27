Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E156C6B0333
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 09:32:14 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id i18so16592815wrb.21
        for <linux-mm@kvack.org>; Mon, 27 Mar 2017 06:32:14 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id v22si791180wra.229.2017.03.27.06.32.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Mar 2017 06:32:13 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id 07F1C1C2161
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 14:32:13 +0100 (IST)
Date: Mon, 27 Mar 2017 14:32:12 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: Page allocator order-0 optimizations merged
Message-ID: <20170327133212.6azfgrariwocdzzd@techsingularity.net>
References: <d4c1625e-cacf-52a9-bfcb-b32a185a2008@mellanox.com>
 <83a0e3ef-acfa-a2af-2770-b9a92bda41bb@mellanox.com>
 <20170322234004.kffsce4owewgpqnm@techsingularity.net>
 <20170323144347.1e6f29de@redhat.com>
 <20170323145133.twzt4f5ci26vdyut@techsingularity.net>
 <779ab72d-94b9-1a28-c192-377e91383b4e@gmail.com>
 <1fc7338f-2b36-75f7-8a7e-8321f062207b@gmail.com>
 <2123321554.7161128.1490599967015.JavaMail.zimbra@redhat.com>
 <20170327105514.1ed5b1ba@redhat.com>
 <20170327143947.4c237e54@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170327143947.4c237e54@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Pankaj Gupta <pagupta@redhat.com>, Tariq Toukan <ttoukan.linux@gmail.com>, Tariq Toukan <tariqt@mellanox.com>, netdev@vger.kernel.org, akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>, Saeed Mahameed <saeedm@mellanox.com>

On Mon, Mar 27, 2017 at 02:39:47PM +0200, Jesper Dangaard Brouer wrote:
> On Mon, 27 Mar 2017 10:55:14 +0200
> Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> 
> > A possible solution, would be use the local_bh_{disable,enable} instead
> > of the {preempt_disable,enable} calls.  But it is slower, using numbers
> > from [1] (19 vs 11 cycles), thus the expected cycles saving is 38-19=19.
> > 
> > The problematic part of using local_bh_enable is that this adds a
> > softirq/bottom-halves rescheduling point (as it checks for pending
> > BHs).  Thus, this might affects real workloads.
> 
> I implemented this solution in patch below... and tested it on mlx5 at
> 50G with manually disabled driver-page-recycling.  It works for me.
> 
> To Mel, that do you prefer... a partial-revert or something like this?
> 

If Tariq confirms it works for him as well, this looks far safer patch
than having a dedicate IRQ-safe queue. Your concern about the BH
scheduling point is valid but if it's proven to be a problem, there is
still the option of a partial revert.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
