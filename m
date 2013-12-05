Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 7F3566B0035
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 10:16:47 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id g10so24815946pdj.31
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 07:16:47 -0800 (PST)
Received: from g4t0016.houston.hp.com (g4t0016.houston.hp.com. [15.201.24.19])
        by mx.google.com with ESMTPS id wv1si22001693pab.283.2013.12.05.07.16.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Dec 2013 07:16:46 -0800 (PST)
Message-ID: <1386256309.1791.253.camel@misato.fc.hp.com>
Subject: Re: [PATCH] mm, x86: Skip NUMA_NO_NODE while parsing SLIT
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 05 Dec 2013 08:11:49 -0700
In-Reply-To: <52A054A0.6060108@jp.fujitsu.com>
References: <1386191348-4696-1-git-send-email-toshi.kani@hp.com>
	 <52A054A0.6060108@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, mingo@kernel.org, hpa@zytor.com, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org

On Thu, 2013-12-05 at 19:25 +0900, Yasuaki Ishimatsu wrote:
> (2013/12/05 6:09), Toshi Kani wrote:
> > When ACPI SLIT table has an I/O locality (i.e. a locality unique
> > to an I/O device), numa_set_distance() emits the warning message
> > below.
> > 
> >   NUMA: Warning: node ids are out of bound, from=-1 to=-1 distance=10
> > 
> > acpi_numa_slit_init() calls numa_set_distance() with pxm_to_node(),
> > which assumes that all localities have been parsed with SRAT previously.
> > SRAT does not list I/O localities, where as SLIT lists all localities
> 
> > including I/Os.  Hence, pxm_to_node() returns NUMA_NO_NODE (-1) for
> > an I/O locality.  I/O localities are not supported and are ignored
> > today, but emitting such warning message leads unnecessary confusion.
> 
> In this case, the warning message should not be shown. But if SLIT table
> is really broken, the message should be shown. Your patch seems to not care
> for second case.

In the second case, I assume you are worrying about the case of SLIT
table with bad locality numbers.  Since SLIT is a matrix of the number
of localities, it is only possible by making the table bigger than
necessary.  Such excessive localities are safe to ignore (as they are
ignored today) and regular users have nothing to concern about them.
The warning message in this case may be helpful for platform vendors to
test their firmware, but they have plenty of other methods to verify
their SLIT table.

Thanks,
-Toshi



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
