Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9F4A46B0007
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 08:47:06 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r21-v6so1694912edp.23
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 05:47:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a26-v6sor1518308edn.39.2018.08.03.05.47.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 Aug 2018 05:47:05 -0700 (PDT)
Date: Fri, 3 Aug 2018 15:47:01 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH] mm:bugfix check return value of ioremap_prot
Message-ID: <20180803124631.GA13803@avx2>
References: <1533195441-58594-1-git-send-email-chenjie6@huawei.com>
 <CAHbLzkpj9chSMFWWhSb1hTL86rWdys3a=2oHgLjp_e-mDGF1Sw@mail.gmail.com>
 <20180802140222.5957911883678f8271f636aa@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180802140222.5957911883678f8271f636aa@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yang Shi <shy828301@gmail.com>, chenjie6@huawei.com, linux-mm@kvack.org, tj@kernel.org, lizefan@huawei.com

On Thu, Aug 02, 2018 at 02:02:22PM -0700, Andrew Morton wrote:
> On Thu, 2 Aug 2018 09:47:52 -0700 Yang Shi <shy828301@gmail.com> wrote:
> 
> > On Thu, Aug 2, 2018 at 12:37 AM,  <chenjie6@huawei.com> wrote:
> > > From: chen jie <chen jie@chenjie6@huwei.com>
> > >
> > >         ioremap_prot can return NULL which could lead to an oops
> > 
> > What oops? You'd better to have the oops information in your commit log.
> 
> Doesn't matter much - the code is clearly buggy.
> 
> Looking at the callers, I have suspicions about
> fs/proc/base.c:environ_read().  It's assuming that access_remote_vm()
> returns an errno.  But it doesn't - it returns number of bytes copied.
> 
> Alexey, could you please take a look?  While in there, I'd suggest
> adding some return value documentation to __access_remote_vm() and
> access_remote_vm().  Thanks.

This is true: remote VM accessors return number of bytes copied
but ->access returns len/-E. Returning "int" is deceptive.
