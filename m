Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9A0E56B0023
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 04:04:15 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id g6-v6so3677668lfg.14
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 01:04:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z68sor2008281lje.2.2018.03.23.01.04.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Mar 2018 01:04:13 -0700 (PDT)
Subject: Re: [PATCH 3/4] mm: Add free()
References: <20180322195819.24271-1-willy@infradead.org>
 <20180322195819.24271-4-willy@infradead.org>
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Message-ID: <1e95ce64-828b-1214-a930-1ffaedfa00b8@rasmusvillemoes.dk>
Date: Fri, 23 Mar 2018 09:04:10 +0100
MIME-Version: 1.0
In-Reply-To: <20180322195819.24271-4-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On 2018-03-22 20:58, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> free() can free many different kinds of memory.

I'd be a bit worried about using that name. gcc very much knows about
the C standard's definition of that function, as can be seen on
godbolt.org by compiling

void free(const void *);
void f(void)
{
    free((void*)0);
}

with -O2 -Wall -Wextra -c. Anything from 4.6 onwards simply compiles this to

f:
 repz retq

And sure, your free() implementation obviously also has that property,
but I'm worried that they might one day decide to warn about the
prototype mismatch (actually, I'm surprised it doesn't warn now, given
that it obviously pretends to know what free() function I'm calling...),
or make some crazy optimization that will break stuff in very subtle ways.

Also, we probably don't want people starting to use free() (or whatever
name is chosen) if they do know the kind of memory they're freeing?
Maybe it should not be advertised that widely (i.e., in kernel.h).

Rasmus
