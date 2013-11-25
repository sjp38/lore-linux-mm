Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f173.google.com (mail-ve0-f173.google.com [209.85.128.173])
	by kanga.kvack.org (Postfix) with ESMTP id 11E186B0036
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 18:30:48 -0500 (EST)
Received: by mail-ve0-f173.google.com with SMTP id oz11so3426294veb.18
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 15:30:47 -0800 (PST)
Received: from mail-ve0-f179.google.com (mail-ve0-f179.google.com [209.85.128.179])
        by mx.google.com with ESMTPS id ef6si18525217ved.85.2013.11.25.15.30.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 25 Nov 2013 15:30:47 -0800 (PST)
Received: by mail-ve0-f179.google.com with SMTP id jw12so3544531veb.10
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 15:30:46 -0800 (PST)
MIME-Version: 1.0
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 25 Nov 2013 15:30:26 -0800
Message-ID: <CALCETrU9bLB2WziLCd9sopMoQVLhs7wXUj_=wOrV+Oh6T05PDQ@mail.gmail.com>
Subject: Race in check_stack_guard_page?
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

I was looking at the stack expansion code, and I'm not convinced it's
safe.  Aside from the obvious scariness of down_read(&mmap_sem) not
actually preventing vma changes, I think there's a real race.  Suppose
that you have a VM_GROWSDOWN vma above a VM_GROWSUP vma with a
single-page gap between them.  Suppose further that they have
different anon_vma roots.

If one ends up in expand_downwards and the other ends up in
expand_upwards at the same time, then each one can take
page_table_lock without re-checking that there's still room to expand.
 The result will be two vmas that share a page.

(This is presumably only possible on ia64.)

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
