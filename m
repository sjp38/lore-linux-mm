Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0CE706B0035
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 15:15:34 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id g10so3282457pdj.14
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 12:15:34 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id id4si10915850pbc.140.2014.06.20.12.15.33
        for <linux-mm@kvack.org>;
        Fri, 20 Jun 2014 12:15:34 -0700 (PDT)
Date: Fri, 20 Jun 2014 12:15:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [next:master 182/217] include/linux/compiler.h:109:18: warning:
 format '%u' expects argument of type 'unsigned int', but argument 6 has
 type 'long unsigned int'
Message-Id: <20140620121532.6fd1279fd270e5109dd66693@linux-foundation.org>
In-Reply-To: <53a40933.iohxcHMNyZQcSVyQ%fengguang.wu@intel.com>
References: <53a40933.iohxcHMNyZQcSVyQ%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Yinghai Lu <yinghai@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org

On Fri, 20 Jun 2014 18:13:07 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   633594bb2d3890711a887897f2003f41735f0dfa
> commit: 8d9dfa4b0125b04eb215909a388cf83fcdeee719 [182/217] initramfs: support initramfs that is more than 2G
> config: i386-randconfig-j1-06201406 (attached as .config)
> 
> All warnings:
> 
>    In file included from include/linux/init.h:4:0,
>                     from crypto/zlib.c:25:
>    crypto/zlib.c: In function 'zlib_compress_update':
>    include/linux/compiler.h:109:18: warning: format '%u' expects argument of type 'unsigned int', but argument 4 has type 'uLong' [-Wformat=]
>        static struct ftrace_branch_data  \

Simple fix is below.

But things still aren't very good. 
initramfs-support-initramfs-that-is-more-than-2g.patch switches
avail_in and avail_out from uint to ulong but failed to fix up a whole
bunch of code which expects to handle 32-bit quantities.

eg:

static int zlib_compress_update(struct crypto_pcomp *tfm,
				struct comp_request *req)
{
	int ret;

	...

	ret = req->avail_out - stream->avail_out;

This is at least sloppy and is quite possibly buggy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
