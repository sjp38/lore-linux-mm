Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id F11866B0005
	for <linux-mm@kvack.org>; Mon,  7 May 2018 18:25:39 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id a6-v6so597207pll.22
        for <linux-mm@kvack.org>; Mon, 07 May 2018 15:25:39 -0700 (PDT)
Received: from mail.ewheeler.net (mx.ewheeler.net. [66.155.3.69])
        by mx.google.com with ESMTP id g34-v6si22845406pld.411.2018.05.07.15.25.38
        for <linux-mm@kvack.org>;
        Mon, 07 May 2018 15:25:38 -0700 (PDT)
Received: from localhost (localhost [127.0.0.1])
	by mail.ewheeler.net (Postfix) with ESMTP id 0BC4AA0414
	for <linux-mm@kvack.org>; Mon,  7 May 2018 22:25:38 +0000 (UTC)
Received: from mail.ewheeler.net ([127.0.0.1])
	by localhost (mail.ewheeler.net [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id VMcguTNd1mOo for <linux-mm@kvack.org>;
	Mon,  7 May 2018 22:25:37 +0000 (UTC)
Received: from mx.ewheeler.net (mx.ewheeler.net [66.155.3.69])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.ewheeler.net (Postfix) with ESMTPSA id 82751A03B0
	for <linux-mm@kvack.org>; Mon,  7 May 2018 22:25:37 +0000 (UTC)
Date: Mon, 7 May 2018 22:25:35 +0000 (UTC)
From: Eric Wheeler <linux-mm@lists.ewheeler.net>
Subject: Copy-on-write with vmalloc
Message-ID: <alpine.LRH.2.11.1805072224360.31774@mail.ewheeler.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hello all,

I would like to clone a virtual address space so that the address spaces 
share physical pages until a write happens, at which point it would copy 
to a new physical page.  I've looked around and haven't found any 
documentation. Certainly fork() already does this, but is there already 
simple way to do it with a virtual address space?

That is, does anything already implement the hypothetical vmalloc_clone 
in this example (4k pages):

	v = vmalloc(1024*1024);

	v[0] = 1;
	v[4096] = 2;

	v_copy = vmalloc_clone(v);

	v_copy[0] = 3;     /* copy-on-write */

And then the following expressions would still be true:

	/* different pages */
	v[0] == 1;
	v_copy[0] == 3; 

	/* shared page */
	v[4096] == 2;
	v_copy[4096] == 2; 

Thank you for your help!

--
Eric Wheeler
