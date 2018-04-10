Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 174FF6B0003
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 05:40:50 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id y64-v6so330680lfc.10
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 02:40:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o22sor598745ljc.75.2018.04.10.02.40.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Apr 2018 02:40:48 -0700 (PDT)
Date: Tue, 10 Apr 2018 12:40:47 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [v3 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
Message-ID: <20180410094047.GB2041@uranus.lan>
References: <1523310774-40300-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180410090917.GZ21835@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180410090917.GZ21835@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, adobriyan@gmail.com, willy@infradead.org, mguzik@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Apr 10, 2018 at 11:09:17AM +0200, Michal Hocko wrote:
> On Tue 10-04-18 05:52:54, Yang Shi wrote:
> [...]
> > So, introduce a new spinlock in mm_struct to protect the concurrent
> > access to arg_start|end, env_start|end and others except start_brk and
> > brk, which are still protected by mmap_sem to avoid concurrent access
> > from do_brk().
> 
> Is there any fundamental problem with brk using the same lock?

Seems so. Look into mm/mmap.c:brk syscall which reads and writes
brk value under mmap_sem ('cause of do_brk called inside).
