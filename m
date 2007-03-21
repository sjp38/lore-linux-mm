Message-ID: <4601586E.302@redhat.com>
Date: Wed, 21 Mar 2007 12:08:14 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] split file and anonymous page queues #3
References: <46005B4A.6050307@redhat.com>	<17920.61568.770999.626623@gargle.gargle.HOWL>	<460115D9.7030806@redhat.com>	<17921.7074.900919.784218@gargle.gargle.HOWL>	<46011E8F.2000109@redhat.com>	<46011EF6.3040704@redhat.com> <17921.20299.7899.527765@gargle.gargle.HOWL>
In-Reply-To: <17921.20299.7899.527765@gargle.gargle.HOWL>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nikita Danilov wrote:

> Generally speaking, multi-queue replacement mechanisms were tried in the
> past, and they all suffer from the common drawback: once scanning rate
> is different for different queues, so is the notion of "hotness",
> measured by scanner. As a result multi-queue scanner fails to capture
> working set properly.

You realize that the current "single" queue in the 2.6 kernel
has this problem in a much worse way: when swappiness is low
and the kernel does not want to reclaim mapped pages, it will
randomly rotate those pages around the list.

In addition, the referenced bit on unmapped page cache pages
was ignored completely, making it impossible for the VM to
separate the page cache working set from transient pages due
to streaming IO.

I agree that we should put some more negative feedback in
place if it turns out we need it.  I have refault code ready
that can be plugged into this patch, but I don't want to add
the overhead of such code if it turns out we do not actually
need it.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
