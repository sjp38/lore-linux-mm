Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f175.google.com (mail-vc0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 099C26B0038
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 08:41:19 -0400 (EDT)
Received: by mail-vc0-f175.google.com with SMTP id id10so1285386vcb.6
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 05:41:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id jq10si2886295vdb.75.2014.10.02.05.41.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Oct 2014 05:41:18 -0700 (PDT)
Date: Thu, 2 Oct 2014 14:40:43 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/4] mm: gup: add get_user_pages_locked and
 get_user_pages_unlocked
Message-ID: <20141002124043.GC2342@redhat.com>
References: <1412153797-6667-1-git-send-email-aarcange@redhat.com>
 <1412153797-6667-3-git-send-email-aarcange@redhat.com>
 <20141001155159.GA7019@google.com>
 <CAJu=L58vaT7BXfR+RHZ397zJJYL9KwozN0qzCQRadm-=wVYcUw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJu=L58vaT7BXfR+RHZ397zJJYL9KwozN0qzCQRadm-=wVYcUw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>
Cc: Peter Feiner <pfeiner@google.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, "\\Dr. David Alan Gilbert\\" <dgilbert@redhat.com>

On Wed, Oct 01, 2014 at 10:06:27AM -0700, Andres Lagar-Cavilla wrote:
> On Wed, Oct 1, 2014 at 8:51 AM, Peter Feiner <pfeiner@google.com> wrote:
> > On Wed, Oct 01, 2014 at 10:56:35AM +0200, Andrea Arcangeli wrote:
> >> +             /* VM_FAULT_RETRY cannot return errors */
> >> +             if (!*locked) {
> >> +                     BUG_ON(ret < 0);
> >> +                     BUG_ON(nr_pages == 1 && ret);
> >
> > If I understand correctly, this second BUG_ON is asserting that when
> > __get_user_pages is asked for a single page and it is successfully gets the
> > page, then it shouldn't have dropped the mmap_sem. If that's the case, then
> > you could generalize this assertion to
> >
> >                         BUG_ON(nr_pages == ret);

Agreed.

> 
> Even more strict:
>      BUG_ON(ret >= nr_pages);

Agreed too, plus this should be quicker than my weaker check.

Maybe some BUG_ON can be deleted later or converted to VM_BUG_ON, but
initially I feel safer with the BUG_ON considering that is a slow
path.

> Reviewed-by: Andres Lagar-Cavilla <andreslc@google.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
