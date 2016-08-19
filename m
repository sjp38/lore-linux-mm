Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 058DE6B0261
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 16:18:48 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id j124so8604165ith.2
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 13:18:48 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0217.hostedemail.com. [216.40.44.217])
        by mx.google.com with ESMTPS id l143si9630488iol.251.2016.08.19.13.18.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Aug 2016 13:18:47 -0700 (PDT)
Message-ID: <1471637924.3893.48.camel@perches.com>
Subject: Re: [PATCH 0/2] fs, proc: optimize smaps output formatting
From: Joe Perches <joe@perches.com>
Date: Fri, 19 Aug 2016 13:18:44 -0700
In-Reply-To: <1471628595.3893.23.camel@perches.com>
References: <1471519888-13829-1-git-send-email-mhocko@kernel.org>
	 <1471601580-17999-1-git-send-email-mhocko@kernel.org>
	 <1471628595.3893.23.camel@perches.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jann Horn <jann@thejh.net>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, 2016-08-19 at 10:43 -0700, Joe Perches wrote:
> And this would definitely be faster if seq_has_overflowed() was
> used somewhere in the iteration loop.

Adding a seq_has_overflowed() test seems unnecessary as the
fs/seq_file.c traverse() static function already does a
seq_has_overflowed().

And I get:

$ t_mm (your allocate all vma program modified to show count)
count: 65514 pid:2051
$ wc -c /proc/2051/smaps 
39515615 /proc/2051/smaps

smap vma output is a little more than 600 bytes per vma.

I'll look around to see how best go use single_open_size
assuming 768 bytes/vma rounded up to the next PAGE_SIZE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
