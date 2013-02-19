Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 0F8916B0005
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 16:32:25 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id um15so2459829pbc.14
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 13:32:25 -0800 (PST)
Date: Tue, 19 Feb 2013 13:32:23 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] mm: protect si_meminfo() and si_meminfo_node() from
 memory hotplug operations
In-Reply-To: <1361032046-1725-2-git-send-email-jiang.liu@huawei.com>
Message-ID: <alpine.DEB.2.02.1302191331210.6322@chino.kir.corp.google.com>
References: <1361032046-1725-1-git-send-email-jiang.liu@huawei.com> <1361032046-1725-2-git-send-email-jiang.liu@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <liuj97@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, sworddragon2@aol.com, Jiang Liu <jiang.liu@huawei.com>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On Sun, 17 Feb 2013, Jiang Liu wrote:

> There's typical usage of si_meminfo as below:
> 	si_meminfo(&si);
> 	threshold = si->totalram - si.totalhigh;
> 
> It may cause underflow if memory hotplug races with si_meminfo() because
> there's no mechanism to protect si_meminfo() from memory hotplug
> operations. And some callers expects that si_meminfo() is a lightweight
> operations. So introduce a lightweight mechanism to protect si_meminfo()
> from memory hotplug operations.
> 

Instead of this, I think it would be appropriate to add a comment that 
requires synchronization if two fields are going to be compared, i.e. use 
{lock,unlock}_memory_hotplug() in the caller to si_meminfo(), or 
appropriate underflow checking is done upon return.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
