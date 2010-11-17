Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6F2646B0127
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 13:28:59 -0500 (EST)
Received: by wwb18 with SMTP id 18so442448wwb.26
        for <linux-mm@kvack.org>; Wed, 17 Nov 2010 10:28:53 -0800 (PST)
Subject: Re: percpu: Implement this_cpu_add,sub,dec,inc_return
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1011100939530.23566@router.home>
References: <alpine.DEB.2.00.1011091124490.9898@router.home>
	 <alpine.DEB.2.00.1011100939530.23566@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 17 Nov 2010 19:28:47 +0100
Message-ID: <1290018527.2687.108.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Le mercredi 10 novembre 2010 A  09:40 -0600, Christoph Lameter a A(C)crit :
> Tried it. This is the result.
> 
> 
> Implement this_cpu_add_return and friends and supply an optimized
> implementation for x86.
> 
> Use this_cpu_add_return for vmstats and nmi processing.
> 
> There is no win in terms of code size (stays the same because xadd is a
> longer instruction thaninc and requires loading a constant in a register first)
> but we eliminate one memory access.
> 
> Plus we introduce a more flexible way of per cpu atomic operations.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> ---

I believe this new xx_return stuff would be useful on x86_32 :
#if defined(CONFIG_HIGHMEM) || defined(CONFIG_X86_32)

kmap_atomic_idx_push() / kmap_atomic_idx_pop() are a bit expensive
because :

c102a652:       0f 01 3b                invlpg (%ebx)
	int idx = --__get_cpu_var(__kmap_atomic_idx);
c102a655:       64 03 3d 90 40 5f c1    add    %fs:0xc15f4090,%edi
c102a65c:       8b 07                   mov    (%edi),%eax
c102a65e:       83 e8 01                sub    $0x1,%eax
c102a661:       85 c0                   test   %eax,%eax
c102a663:       89 07                   mov    %eax,(%edi)





diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index b676c58..bb5db26 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -91,7 +91,7 @@ static inline int kmap_atomic_idx_push(void)
 
 static inline int kmap_atomic_idx(void)
 {
-	return __get_cpu_var(__kmap_atomic_idx) - 1;
+	return __this_cpu_read(__kmap_atomic_idx) - 1;
 }
 
 static inline int kmap_atomic_idx_pop(void)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
