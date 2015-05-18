Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id A7FC96B0032
	for <linux-mm@kvack.org>; Mon, 18 May 2015 18:12:35 -0400 (EDT)
Received: by obcus9 with SMTP id us9so142957217obc.2
        for <linux-mm@kvack.org>; Mon, 18 May 2015 15:12:35 -0700 (PDT)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id g8si7203718oep.106.2015.05.18.15.12.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 15:12:34 -0700 (PDT)
Message-ID: <1431985994.21526.12.camel@misato.fc.hp.com>
Subject: Re: [PATCH v5 6/6] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 18 May 2015 15:53:14 -0600
In-Reply-To: <20150518205123.GI23618@pd.tnic>
References: <1431714237-880-1-git-send-email-toshi.kani@hp.com>
	 <1431714237-880-7-git-send-email-toshi.kani@hp.com>
	 <20150518133348.GA23618@pd.tnic>
	 <1431969759.19889.5.camel@misato.fc.hp.com>
	 <20150518190150.GC23618@pd.tnic>
	 <1431977519.20569.15.camel@misato.fc.hp.com>
	 <20150518200114.GE23618@pd.tnic>
	 <1431980468.21019.11.camel@misato.fc.hp.com>
	 <20150518205123.GI23618@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, mcgrof@suse.com

On Mon, 2015-05-18 at 22:51 +0200, Borislav Petkov wrote:
> On Mon, May 18, 2015 at 02:21:08PM -0600, Toshi Kani wrote:
> > The caller is the one who makes the condition checks necessary to create
> > a huge page mapping.
> 
> How? It would go and change MTRRs configuration and ranges and their
> memory types so that a huge mapping succeeds?
> 
> Or go and try a different range?

Try with a smaller page size.

The callers, pud_set_huge() and pmd_set_huge(), check if the given range
is safe with MTRRs for creating a huge page mapping.  If not, they fail
the request, which leads their callers, ioremap_pud_range() and
ioremap_pmd_range(), to retry with a smaller page size, i.e. 1GB -> 2MB
-> 4KB.  4KB may not have overlap with MTRRs (hence no checking is
necessary), which will succeed as before.

Thanks,
-Toshi




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
