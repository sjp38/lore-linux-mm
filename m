Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 609046B0038
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 19:53:59 -0500 (EST)
Received: by pasz6 with SMTP id z6so48051910pas.2
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 16:53:59 -0800 (PST)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id sg1si16019767pac.95.2015.11.11.16.53.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Nov 2015 16:53:58 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so46425481pac.3
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 16:53:58 -0800 (PST)
Date: Thu, 12 Nov 2015 09:54:55 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 2/3] tools/vm/page-types: suppress gcc warnings
Message-ID: <20151112005455.GA1651@swordfish>
References: <1447162326-30626-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1447162326-30626-3-git-send-email-sergey.senozhatsky@gmail.com>
 <alpine.DEB.2.10.1511111242060.3565@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.10.1511111242060.3565@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On (11/11/15 12:44), David Rientjes wrote:
[..]
> This can't possibly be correct, the warnings are legitimate and the result
> of the sigsetjmp() in the function.  You may be interested in
> returns_twice rather than marking random automatic variables as volatile.

Hm, ok. I saw no probs with `int first' and `end' being volatile

static void walk_file(const char *name, const struct stat *st)
{
	int first = 1;

	for (...) {

		if (sigsetjmp(sigbus_jmp, 1)) {
			goto got_sigbus;
		}

got_sigbus:
		...
		if (first && opt_list) {
			first = 0;
			print_foo();
		}
	}
}


the `end' is also looked fine.


ANSI C

?7.13.2.1

3 All accessible objects have values, and all other components of the abstract machine 249)
  have state, as of the time the longjmp function was called, except that the values of
  objects of automatic storage duration that are local to the function containing the
  invocation of the corresponding setjmp macro that do not have volatile-qualified type
                                                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  and have been changed between the setjmp invocation and longjmp call are indeterminate.


Thus, adding 'volatile' should do the trick. Isn't it?
I need to google more - is returns_twice actually prevents gcc from
`over-optimizing' (there are some bug reports that state that setjmp can
be screwed up by gcc) or it's actually because the programs that do setjmp
basically violate ANSI C standard and don't volatile-qualify the affected
variables. Any hint would be helpful.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
