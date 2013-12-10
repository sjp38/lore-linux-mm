Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 82A186B0132
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 19:11:37 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so6127228pdj.40
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 16:11:37 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id qx4si8708464pbc.135.2013.12.09.16.11.35
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 16:11:35 -0800 (PST)
Date: Mon, 9 Dec 2013 16:11:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 02/23] mm/memblock: debug: don't free reserved array
 if !ARCH_DISCARD_MEMBLOCK
Message-Id: <20131209161134.e161ddfedf284f2052cad4a5@linux-foundation.org>
In-Reply-To: <1386625856-12942-3-git-send-email-santosh.shilimkar@ti.com>
References: <1386625856-12942-1-git-send-email-santosh.shilimkar@ti.com>
	<1386625856-12942-3-git-send-email-santosh.shilimkar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Grygorii Strashko <grygorii.strashko@ti.com>, Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>

On Mon, 9 Dec 2013 16:50:35 -0500 Santosh Shilimkar <santosh.shilimkar@ti.com> wrote:

> Now the Nobootmem allocator will always try to free memory allocated for
> reserved memory regions (free_low_memory_core_early()) without taking
> into to account current memblock debugging configuration
> (CONFIG_ARCH_DISCARD_MEMBLOCK and CONFIG_DEBUG_FS state).
> As result if:
>  - CONFIG_DEBUG_FS defined
>  - CONFIG_ARCH_DISCARD_MEMBLOCK not defined;
> -  reserved memory regions array have been resized during boot
> 
> then:
> - memory allocated for reserved memory regions array will be freed to
> buddy allocator;
> - debug_fs entry "sys/kernel/debug/memblock/reserved" will show garbage
> instead of state of memory reservations. like:
>    0: 0x98393bc0..0x9a393bbf
>    1: 0xff120000..0xff11ffff
>    2: 0x00000000..0xffffffff
> 
> Hence, do not free memory allocated for reserved memory regions if
> defined(CONFIG_DEBUG_FS) && !defined(CONFIG_ARCH_DISCARD_MEMBLOCK).

Alternatives:

- disable /proc/sys/kernel/debug/memblock/reserved in this case

- disable defined(CONFIG_DEBUG_FS) &&
  !defined(CONFIG_ARCH_DISCARD_MEMBLOCK) in Kconfig.

How much memory are we talking about here?  If it's more than "very
little" then I think either of these would be better - most users will
value the extra memory over an accurate
/proc/sys/kernel/debug/memblock/reserved?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
