Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id E5AB86B0069
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 07:35:17 -0400 (EDT)
Date: Mon, 29 Oct 2012 07:35:15 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: [PATCH v7 06/16] tracepoint: use new hashtable implementation
Message-ID: <20121029113515.GB9115@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com> <1351450948-15618-6-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <1351450948-15618-6-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

* Sasha Levin (levinsasha928@gmail.com) wrote:
> Switch tracepoints to use the new hashtable implementation. This reduces =
the amount of
> generic unrelated code in the tracepoints.
>=20
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
>  kernel/tracepoint.c | 27 +++++++++++----------------
>  1 file changed, 11 insertions(+), 16 deletions(-)
>=20
> diff --git a/kernel/tracepoint.c b/kernel/tracepoint.c
> index d96ba22..854df92 100644
> --- a/kernel/tracepoint.c
> +++ b/kernel/tracepoint.c
> @@ -26,6 +26,7 @@
>  #include <linux/slab.h>
>  #include <linux/sched.h>
>  #include <linux/static_key.h>
> +#include <linux/hashtable.h>
> =20
>  extern struct tracepoint * const __start___tracepoints_ptrs[];
>  extern struct tracepoint * const __stop___tracepoints_ptrs[];
> @@ -49,8 +50,7 @@ static LIST_HEAD(tracepoint_module_list);
>   * Protected by tracepoints_mutex.
>   */
>  #define TRACEPOINT_HASH_BITS 6
> -#define TRACEPOINT_TABLE_SIZE (1 << TRACEPOINT_HASH_BITS)
> -static struct hlist_head tracepoint_table[TRACEPOINT_TABLE_SIZE];
> +static DEFINE_HASHTABLE(tracepoint_table, TRACEPOINT_HASH_BITS);
> =20
[...]
> =20
> @@ -722,6 +715,8 @@ struct notifier_block tracepoint_module_nb =3D {
> =20
>  static int init_tracepoints(void)
>  {
> +	hash_init(tracepoint_table);
> +
>  	return register_module_notifier(&tracepoint_module_nb);
>  }
>  __initcall(init_tracepoints);

So we have a hash table defined in .bss (therefore entirely initialized
to NULL), and you add a call to "hash_init", which iterates on the whole
array and initialize it to NULL (again) ?

This extra initialization is redundant. I think it should be removed
=66rom here, and hashtable.h should document that hash_init() don't need
to be called on zeroed memory (which includes static/global variables,
kzalloc'd memory, etc).

Thanks,

Mathieu

--=20
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
