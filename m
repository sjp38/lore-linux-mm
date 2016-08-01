Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A50D46B0253
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 16:30:12 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 63so293916780pfx.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 13:30:12 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o4si700458pac.86.2016.08.01.13.30.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 13:30:12 -0700 (PDT)
Date: Mon, 1 Aug 2016 13:30:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] kasan: avoid overflowing quarantine size on low memory
 systems
Message-Id: <20160801133010.08b1733dc7f62fe68713c0ba@linux-foundation.org>
In-Reply-To: <1470063563-96266-1-git-send-email-glider@google.com>
References: <1470063563-96266-1-git-send-email-glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: dvyukov@google.com, kcc@google.com, aryabinin@virtuozzo.com, adech.fo@gmail.com, cl@linux.com, rostedt@goodmis.org, js1304@gmail.com, iamjoonsoo.kim@lge.com, kuthonuzo.luruo@hpe.com, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon,  1 Aug 2016 16:59:23 +0200 Alexander Potapenko <glider@google.com> wrote:

> If the total amount of memory assigned to quarantine is less than the
> amount of memory assigned to per-cpu quarantines, |new_quarantine_size|
> may overflow. Instead, set it to zero.
> 
> --- a/mm/kasan/quarantine.c
> +++ b/mm/kasan/quarantine.c
> @@ -214,7 +214,15 @@ void quarantine_reduce(void)
>  	 */
>  	new_quarantine_size = (READ_ONCE(totalram_pages) << PAGE_SHIFT) /
>  		QUARANTINE_FRACTION;
> -	new_quarantine_size -= QUARANTINE_PERCPU_SIZE * num_online_cpus();
> +	percpu_quarantines = QUARANTINE_PERCPU_SIZE * num_online_cpus();
> +	if (new_quarantine_size < percpu_quarantines) {
> +		WARN_ONCE(1,
> +			"Too little memory, disabling global KASAN quarantine.\n",
> +		);
> +		new_quarantine_size = 0;
> +	} else {
> +		new_quarantine_size -= percpu_quarantines;
> +	}
>  	WRITE_ONCE(quarantine_size, new_quarantine_size);
>  
>  	last = global_quarantine.head;

This is a little tidier:

--- a/mm/kasan/quarantine.c~kasan-avoid-overflowing-quarantine-size-on-low-memory-systems-fix
+++ a/mm/kasan/quarantine.c
@@ -217,14 +217,11 @@ void quarantine_reduce(void)
 	new_quarantine_size = (READ_ONCE(totalram_pages) << PAGE_SHIFT) /
 		QUARANTINE_FRACTION;
 	percpu_quarantines = QUARANTINE_PERCPU_SIZE * num_online_cpus();
-	if (new_quarantine_size < percpu_quarantines) {
-		WARN_ONCE(1,
-			"Too little memory, disabling global KASAN quarantine.\n",
-		);
+	if (WARN_ONCE(new_quarantine_size < percpu_quarantines,
+		"Too little memory, disabling global KASAN quarantine.\n"))
 		new_quarantine_size = 0;
-	} else {
+	else
 		new_quarantine_size -= percpu_quarantines;
-	}
 	WRITE_ONCE(quarantine_size, new_quarantine_size);
 
 	last = global_quarantine.head;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
