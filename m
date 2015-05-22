Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 48E0D6B0159
	for <linux-mm@kvack.org>; Fri, 22 May 2015 03:48:43 -0400 (EDT)
Received: by wichy4 with SMTP id hy4so38267972wic.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 00:48:42 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id ek6si2610737wib.51.2015.05.22.00.48.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 22 May 2015 00:48:41 -0700 (PDT)
Date: Fri, 22 May 2015 09:48:41 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v9 8/10] x86, mm: Add set_memory_wt() for WT
In-Reply-To: <1431551151-19124-9-git-send-email-toshi.kani@hp.com>
Message-ID: <alpine.DEB.2.11.1505220944340.5457@nanos>
References: <1431551151-19124-1-git-send-email-toshi.kani@hp.com> <1431551151-19124-9-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@ml01.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de

On Wed, 13 May 2015, Toshi Kani wrote:
> +int set_memory_wt(unsigned long addr, int numpages)
> +{
> +	int ret;
> +
> +	if (!pat_enabled)
> +		return set_memory_uc(addr, numpages);
> +
> +	ret = reserve_memtype(__pa(addr), __pa(addr) + numpages * PAGE_SIZE,
> +			      _PAGE_CACHE_MODE_WT, NULL);
> +	if (ret)
> +		goto out_err;
> +
> +	ret = _set_memory_wt(addr, numpages);
> +	if (ret)
> +		goto out_free;
> +
> +	return 0;
> +
> +out_free:
> +	free_memtype(__pa(addr), __pa(addr) + numpages * PAGE_SIZE);
> +out_err:
> +	return ret;


This goto zoo is horrible to read. What's wrong with a straight forward:

+	if (!pat_enabled)
+		return set_memory_uc(addr, numpages);
+
+	ret = reserve_memtype(__pa(addr), __pa(addr) + numpages * PAGE_SIZE,
+			      _PAGE_CACHE_MODE_WT, NULL);
+	if (ret)
+		return ret;
+
+	ret = _set_memory_wt(addr, numpages);
+	if (ret)
+		free_memtype(__pa(addr), __pa(addr) + numpages * PAGE_SIZE);
+	return ret;

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
