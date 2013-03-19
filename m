Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id ED3C86B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 23:56:15 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y14so18117pdi.8
        for <linux-mm@kvack.org>; Mon, 18 Mar 2013 20:56:15 -0700 (PDT)
Date: Mon, 18 Mar 2013 20:56:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: speedup in __early_pfn_to_nid
In-Reply-To: <20130318155619.GA18828@sgi.com>
Message-ID: <alpine.DEB.2.02.1303182055560.28114@chino.kir.corp.google.com>
References: <20130318155619.GA18828@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russ Anderson <rja@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com

On Mon, 18 Mar 2013, Russ Anderson wrote:

> When booting on a large memory system, the kernel spends
> considerable time in memmap_init_zone() setting up memory zones.
> Analysis shows significant time spent in __early_pfn_to_nid().
> 
> The routine memmap_init_zone() checks each PFN to verify the
> nid is valid.  __early_pfn_to_nid() sequentially scans the list of
> pfn ranges to find the right range and returns the nid.  This does
> not scale well.  On a 4 TB (single rack) system there are 308
> memory ranges to scan.  The higher the PFN the more time spent
> sequentially spinning through memory ranges.
> 
> Since memmap_init_zone() increments pfn, it will almost always be
> looking for the same range as the previous pfn, so check that
> range first.  If it is in the same range, return that nid.
> If not, scan the list as before.
> 
> A 4 TB (single rack) UV1 system takes 512 seconds to get through
> the zone code.  This performance optimization reduces the time
> by 189 seconds, a 36% improvement.
> 
> A 2 TB (single rack) UV2 system goes from 212.7 seconds to 99.8 seconds,
> a 112.9 second (53%) reduction.
> 
> Signed-off-by: Russ Anderson <rja@sgi.com>

Acked-by: David Rientjes <rientjes@google.com>

Very nice improvement!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
