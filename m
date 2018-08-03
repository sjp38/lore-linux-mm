Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2C3C66B000A
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 19:06:00 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id d10-v6so4036785pll.22
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 16:06:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m9-v6si4437811pll.138.2018.08.03.16.05.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Aug 2018 16:05:59 -0700 (PDT)
Date: Fri, 3 Aug 2018 16:05:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm:bugfix check return value of ioremap_prot
Message-Id: <20180803160557.5d7c5f8e20b526b8bd071146@linux-foundation.org>
In-Reply-To: <20180803124631.GA13803@avx2>
References: <1533195441-58594-1-git-send-email-chenjie6@huawei.com>
	<CAHbLzkpj9chSMFWWhSb1hTL86rWdys3a=2oHgLjp_e-mDGF1Sw@mail.gmail.com>
	<20180802140222.5957911883678f8271f636aa@linux-foundation.org>
	<20180803124631.GA13803@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Yang Shi <shy828301@gmail.com>, chenjie6@huawei.com, linux-mm@kvack.org, tj@kernel.org, lizefan@huawei.com

On Fri, 3 Aug 2018 15:47:01 +0300 Alexey Dobriyan <adobriyan@gmail.com> wrote:

> On Thu, Aug 02, 2018 at 02:02:22PM -0700, Andrew Morton wrote:
> > On Thu, 2 Aug 2018 09:47:52 -0700 Yang Shi <shy828301@gmail.com> wrote:
> > 
> > > On Thu, Aug 2, 2018 at 12:37 AM,  <chenjie6@huawei.com> wrote:
> > > > From: chen jie <chen jie@chenjie6@huwei.com>
> > > >
> > > >         ioremap_prot can return NULL which could lead to an oops
> > > 
> > > What oops? You'd better to have the oops information in your commit log.
> > 
> > Doesn't matter much - the code is clearly buggy.
> > 
> > Looking at the callers, I have suspicions about
> > fs/proc/base.c:environ_read().  It's assuming that access_remote_vm()
> > returns an errno.  But it doesn't - it returns number of bytes copied.
> > 
> > Alexey, could you please take a look?  While in there, I'd suggest
> > adding some return value documentation to __access_remote_vm() and
> > access_remote_vm().  Thanks.
> 
> This is true: remote VM accessors return number of bytes copied
> but ->access returns len/-E. Returning "int" is deceptive.

It's more than deceptive - it's flat-out buggy for >4G copy attempts. 
And highly dubious for 2G-4G copies, where it might return a negative
int.

I suppose that access_remote_vm() should strictly return a ptrdiff_t,
but we hardly ever use that.  size_t will do.
