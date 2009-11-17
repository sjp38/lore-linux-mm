From: Steve French <smfrench@gmail.com>
Subject: Re: [PATCH 6/7] cifs: Don't use PF_MEMALLOC
Date: Tue, 17 Nov 2009 10:40:49 -0600
Message-ID: <524f69650911170840o5be241a0q5d9863c8d7f4e571@mail.gmail.com>
References: <20091117161551.3DD4.A69D9226@jp.fujitsu.com>
	<20091117162111.3DE8.A69D9226@jp.fujitsu.com>
	<20091117074739.4abaef85@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <samba-technical-bounces@lists.samba.org>
In-Reply-To: <20091117074739.4abaef85@tlielax.poochiereds.net>
List-Unsubscribe: <https://lists.samba.org/mailman/options/samba-technical>,
	<mailto:samba-technical-request@lists.samba.org?subject=unsubscribe>
List-Archive: <http://lists.samba.org/pipermail/samba-technical>
List-Post: <mailto:samba-technical@lists.samba.org>
List-Help: <mailto:samba-technical-request@lists.samba.org?subject=help>
List-Subscribe: <https://lists.samba.org/mailman/listinfo/samba-technical>,
	<mailto:samba-technical-request@lists.samba.org?subject=subscribe>
Sender: samba-technical-bounces@lists.samba.org
Errors-To: samba-technical-bounces@lists.samba.org
To: Jeff Layton <jlayton@redhat.com>
Cc: samba-technical@lists.samba.org, LKML <linux-kernel@vger.kernel.org>, Steve French <sfrench@samba.org>, linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-cifs-client@lists.samba.org
List-Id: linux-mm.kvack.org

It is hard to follow exactly what this flag does in /mm (other than try
harder on memory allocations) - I haven't found much about this flag (e.g.
http://lwn.net/Articles/246928/) but it does look like most of the fs no
longer set this (except xfs) e.g. ext3_ordered_writepage.  When running out
of memory in the cifs_demultiplex_thread it will retry 3 seconds later, but
if memory allocations ever fail in this path we could potentially be holding
up (an already issued write in) writepages for that period by not having
memory to get the response to see if the write succeeded.

We pass in few flags for these memory allocation requests: GFP_NOFS (on the
mempool_alloc) and SLAB_HWCACHE_ALIGN (on the kmem_cache_create of the pool)
should we be passing in other flags on the allocations?

On Tue, Nov 17, 2009 at 6:47 AM, Jeff Layton <jlayton@redhat.com> wrote:

> On Tue, 17 Nov 2009 16:22:32 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>
> >
> > Non MM subsystem must not use PF_MEMALLOC. Memory reclaim need few
> > memory, anyone must not prevent it. Otherwise the system cause
> > mysterious hang-up and/or OOM Killer invokation.
> >
> > Cc: Steve French <sfrench@samba.org>
> > Cc: linux-cifs-client@lists.samba.org
> > Cc: samba-technical@lists.samba.org
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > ---
> >  fs/cifs/connect.c |    1 -
> >  1 files changed, 0 insertions(+), 1 deletions(-)
> >
> > diff --git a/fs/cifs/connect.c b/fs/cifs/connect.c
> > index 63ea83f..f9b1553 100644
> > --- a/fs/cifs/connect.c
> > +++ b/fs/cifs/connect.c
> > @@ -337,7 +337,6 @@ cifs_demultiplex_thread(struct TCP_Server_Info
> *server)
> >       bool isMultiRsp;
> >       int reconnect;
> >
> > -     current->flags |= PF_MEMALLOC;
> >       cFYI(1, ("Demultiplex PID: %d", task_pid_nr(current)));
> >
> >       length = atomic_inc_return(&tcpSesAllocCount);
>
> This patch appears to be safe for CIFS. I believe that the demultiplex
> thread only does mempool allocations currently. The only other case
> where it did an allocation was recently changed with the conversion of
> the oplock break code to use slow_work.
>
> Barring anything I've missed...
>
> Acked-by: Jeff Layton <jlayton@redhat.com>
>



-- 
Thanks,

Steve
