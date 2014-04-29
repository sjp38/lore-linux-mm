Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id CAB1D6B0036
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 08:41:07 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d17so279622eek.18
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 05:41:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id d5si26818802eei.358.2014.04.29.05.41.05
        for <linux-mm@kvack.org>;
        Tue, 29 Apr 2014 05:41:06 -0700 (PDT)
Date: Tue, 29 Apr 2014 14:40:53 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [BUG] kernel BUG at mm/vmacache.c:85!
Message-ID: <20140429124053.GA11878@redhat.com>
References: <535EA976.1080402@linux.vnet.ibm.com> <CA+55aFxgW0fS=6xJsKP-WiOUw=aiCEvydj+pc+zDF8Pvn4v+Jw@mail.gmail.com> <CA+55aFzXAnTzfNL-bfUFnu15=4Z9HNigoo-XyjmwRvAWX_xz0A@mail.gmail.com> <1398724754.25549.35.camel@buesod1.americas.hpqcorp.net> <CA+55aFz0jrk-O9gq9VQrFBeWTpLt_5zPt9RsJO9htrqh+nKTfA@mail.gmail.com> <20140428161120.4cad719dc321e3c837db3fd6@linux-foundation.org> <CA+55aFwLSW3V76Y_O37Y8r_yaKQ+y0VMk=6SEEBpeFfGzsJUKA@mail.gmail.com> <1398730319.25549.40.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1398730319.25549.40.camel@buesod1.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>

On 04/28, Davidlohr Bueso wrote:
>
> @@ -29,6 +30,7 @@ void use_mm(struct mm_struct *mm)
>                 tsk->active_mm = mm;
>         }
>         tsk->mm = mm;
> +       vmacache_flush(tsk);

But this can't help, we need to do this in unuse_mm(). And we can race
with vmacache_flush_all() which relies on mmap_sem.

But perhaps WARN_ON(tsk->mm) at the start makes sense...

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
