Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 021DB6B0005
	for <linux-mm@kvack.org>; Sat, 20 Feb 2016 00:54:29 -0500 (EST)
Received: by mail-io0-f177.google.com with SMTP id 9so131190110iom.1
        for <linux-mm@kvack.org>; Fri, 19 Feb 2016 21:54:28 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id e38si26057406ioi.138.2016.02.19.21.54.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Feb 2016 21:54:28 -0800 (PST)
Date: Sat, 20 Feb 2016 16:54:19 +1100
From: Paul Mackerras <paulus@ozlabs.org>
Subject: Re: Problems with THP in v4.5-rc4 on POWER
Message-ID: <20160220055419.GB16191@fergus.ozlabs.ibm.com>
References: <20160220013942.GA16191@fergus.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160220013942.GA16191@fergus.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org

On Sat, Feb 20, 2016 at 12:39:42PM +1100, Paul Mackerras wrote:
> It seems there's something wrong with our transparent hugepage
> implementation on POWER server processors as of v4.5-rc4.  I have seen
> the email thread on "[BUG] random kernel crashes after THP rework on
> s390 (maybe also on PowerPC and ARM)", but this doesn't seem exactly
> the same as that (though it may of course be related).
> 
> I have been testing v4.5-rc4 with Aneesh's patch "powerpc/mm/hash:
> Clear the invalid slot information correctly" on top, on a KVM guest
> with 160 vcpus (threads=8) and 32GB of memory backed by 16MB large
> pages, running on a POWER8 machine running a 4.4.1 host kernel (20
> cores * 8 threads, 128GB of RAM).  The guest kernel is compiled with
> THP enabled and set to "always" (i.e. not "madvise").
> 
> On this setup, when doing something like a large kernel compile, I see
> random segfaults happening (in gcc, cc1, sh, etc.).  I also see bursts
> of messages like this on the host console:
> 
> [50957.570859] Harmless Hypervisor Maintenance interrupt [Recovered]
> [50957.570864]  Error detail: Processor Recovery done
> [50957.570869]  HMER: 2040000000000000

When I use a merge of v4.5-rc4 with the fixes branch from the powerpc
tree, I don't see these messages any more, presumably due to
"powerpc/mm: Fix Multi hit ERAT cause by recent THP update".  With my
patch, I still see that it is finding HPTEs to invalidate, but without
my patch, even though it is presumably leaving HPTEs around, I don't
see any errors (such as random segfaults) occurring.

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
