Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 85DA16B0034
	for <linux-mm@kvack.org>; Sun, 14 Jul 2013 15:27:45 -0400 (EDT)
Received: by mail-ob0-f172.google.com with SMTP id wo10so12982640obc.17
        for <linux-mm@kvack.org>; Sun, 14 Jul 2013 12:27:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130714141154.GA29815@redhat.com>
References: <1373596462-27115-1-git-send-email-ccross@android.com>
	<1373596462-27115-2-git-send-email-ccross@android.com>
	<20130714141154.GA29815@redhat.com>
Date: Sun, 14 Jul 2013 12:27:44 -0700
Message-ID: <CAMbhsRRbz=iQad37f1hbrrGq+YvB27N7NkrO92xWqv_UNOS+ew@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: add a field to store names for private anonymous memory
From: Colin Cross <ccross@android.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Pekka Enberg <penberg@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Jones <davej@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Sun, Jul 14, 2013 at 7:11 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> Sorry if this was already discussed... I am still trying to think if
> we can make a simpler patch.
>
> So, iiuc, the main problem is that if you want to track a vma you need
> to prevent the merging with other vma's.
>
> Question: is it important that vma's with the same vma_name should be
> _merged_ automatically?
>
> If not, can't we make "do not merge" a separate feature and then add
> vma_name?
>
> IOW, please forget about vma_name for the moment. Can't we start with
> the trivial patch below? It simply adds the new vm flag which blocks
> the merging, and MADV_ to set/clear it.
>
> Yes, this is more limited. Once you set VM_TAINTED this vma is always
> isolated. If you unmap a page in this vma, you create 2 isolated vma's.
> If, for example, you do MADV_DONTFORK + MADV_DOFORK inside the tainted
> vma, you will have 2 adjacent VM_TAINTED vma's with the same flags after
> that. But you can do MADV_UNTAINT + MADV_TAINT again if you want to
> merge them back. And perhaps this feature is useful even without the
> naming. And perhaps we can also add MAP_TAINTED.
>
> Now about vma_name. In this case PR_SET_VMA or MADV_NAME should simply
> set/overwrite vma_name and nothing else, no need to do merge/split vma.
>
> And if we add MAP_TAINTED, MAP_ANONYMOUS can reuse pgoff as vma_name
> (we only need a simple changes in do_mmap_pgoff and mmap_region). But
> this is minor.
>
> Or this is too simple/ugly? Probably yes, this means that an allocator
> which simply does a lot of MAP_ANONYMOUS + MADV_TAINT will create more
> vma's than it needs. So I won't insist but I'd like to ask anyway.

This is no different than using a new tmpfs file for every mmap
(although it saves the struct file and the inode), it results in a
huge increase in the number of vmas.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
