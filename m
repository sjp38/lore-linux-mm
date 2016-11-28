Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id EEA926B0069
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 10:04:01 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id j49so94114639qta.1
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 07:04:01 -0800 (PST)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0118.outbound.protection.outlook.com. [104.47.33.118])
        by mx.google.com with ESMTPS id x7si24822371qta.127.2016.11.28.07.04.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 28 Nov 2016 07:04:01 -0800 (PST)
From: Zi Yan <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH 3/5] migrate: Add copy_page_mt to use multi-threaded page
 migration.
Date: Mon, 28 Nov 2016 10:03:46 -0500
Message-ID: <F3961404-1642-4E52-9967-BE03303D8E58@cs.rutgers.edu>
In-Reply-To: <5836B25E.7040100@linux.vnet.ibm.com>
References: <20161122162530.2370-1-zi.yan@sent.com>
 <20161122162530.2370-4-zi.yan@sent.com> <5836B25E.7040100@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
	boundary="=_MailMate_0D94575F-017E-4199-900C-F5F3A4089F0A_=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com

--=_MailMate_0D94575F-017E-4199-900C-F5F3A4089F0A_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 24 Nov 2016, at 4:26, Anshuman Khandual wrote:

> On 11/22/2016 09:55 PM, Zi Yan wrote:
>> From: Zi Yan <zi.yan@cs.rutgers.edu>
>>
>> From: Zi Yan <ziy@nvidia.com>
>
> Please fix these.
>
>>
>> Internally, copy_page_mt splits a page into multiple threads
>> and send them as jobs to system_highpri_wq.
>
> The function should be renamed as copy_page_multithread() or at
> the least copy_page_mthread() to make more sense. The commit
> message needs to more comprehensive and detailed.
>

Sure.

>>
>> Signed-off-by: Zi Yan <ziy@nvidia.com>
>> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
>> ---
>>  include/linux/highmem.h |  2 ++
>>  kernel/sysctl.c         |  1 +
>>  mm/Makefile             |  2 ++
>>  mm/copy_page.c          | 96 ++++++++++++++++++++++++++++++++++++++++=
+++++++++
>>  4 files changed, 101 insertions(+)
>>  create mode 100644 mm/copy_page.c
>>
>> diff --git a/include/linux/highmem.h b/include/linux/highmem.h
>> index bb3f329..519e575 100644
>> --- a/include/linux/highmem.h
>> +++ b/include/linux/highmem.h
>> @@ -236,6 +236,8 @@ static inline void copy_user_highpage(struct page =
*to, struct page *from,
>>
>>  #endif
>>
>> +int copy_page_mt(struct page *to, struct page *from, int nr_pages);
>> +
>>  static inline void copy_highpage(struct page *to, struct page *from)
>>  {
>>  	char *vfrom, *vto;
>> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
>> index 706309f..d54ce12 100644
>> --- a/kernel/sysctl.c
>> +++ b/kernel/sysctl.c
>> @@ -97,6 +97,7 @@
>>
>>  #if defined(CONFIG_SYSCTL)
>>
>> +
>
> I guess this is a stray code change.
>
>>  /* External variables not in a header file. */
>>  extern int suid_dumpable;
>>  #ifdef CONFIG_COREDUMP
>> diff --git a/mm/Makefile b/mm/Makefile
>> index 295bd7a..467305b 100644
>> --- a/mm/Makefile
>> +++ b/mm/Makefile
>> @@ -41,6 +41,8 @@ obj-y			:=3D filemap.o mempool.o oom_kill.o \
>>
>>  obj-y +=3D init-mm.o
>>
>> +obj-y +=3D copy_page.o
>
> Its getting compiled all the time. Dont you want to make it part of
> of a new config option which will cover for all these code for multi
> thread copy ?

I can do that.

>> +
>>  ifdef CONFIG_NO_BOOTMEM
>>  	obj-y		+=3D nobootmem.o
>>  else
>> diff --git a/mm/copy_page.c b/mm/copy_page.c
>> new file mode 100644
>> index 0000000..ca7ce6c
>> --- /dev/null
>> +++ b/mm/copy_page.c
>> @@ -0,0 +1,96 @@
>> +/*
>> + * Parallel page copy routine.
>> + *
>> + * Zi Yan <ziy@nvidia.com>
>> + *
>> + */
>
> No, this is too less. Please see other files inside mm directory as
> example.
>

Sure, I will add more description here.

>> +
>> +#include <linux/highmem.h>
>> +#include <linux/workqueue.h>
>> +#include <linux/slab.h>
>> +#include <linux/freezer.h>
>> +
>> +
>> +const unsigned int limit_mt_num =3D 4;
>
> From where this number 4 came from ? At the very least it should be
> configured from either a sysctl variable or from a sysfs file, so
> that user will have control on number of threads used for copy. But
> going forward this should be derived out a arch specific call back
> which then analyzes NUMA topology and scheduler loads to figure out
> on how many threads should be used for optimum performance of page
> copy.

I will expose this to sysctl.

For finding optimum performance, can we do a boot time microbenchmark
to find the thread number?

For scheduler loads, can we traverse all online CPUs and use idle CPUs
by checking idle_cpu()?


>> +
>> +/* =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D multi-threaded copy page =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D */
>> +
>
> Please use standard exported function description semantics while
> describing this new function. I think its a good function to be
> exported as a symbol as well.
>
>> +struct copy_page_info {
>
> s/copy_page_info/mthread_copy_struct/
>
>> +	struct work_struct copy_page_work;
>> +	char *to;
>> +	char *from;
>
> Swap the order of 'to' and 'from'.
>
>> +	unsigned long chunk_size;
>
> Just 'size' should be fine.
>
>> +};
>> +
>> +static void copy_page_routine(char *vto, char *vfrom,
>
> s/copy_page_routine/mthread_copy_fn/
>
>> +	unsigned long chunk_size)
>> +{
>> +	memcpy(vto, vfrom, chunk_size);
>> +}
>
> s/chunk_size/size/
>
>

Will do the suggested changes in the next version.

>> +
>> +static void copy_page_work_queue_thread(struct work_struct *work)
>> +{
>> +	struct copy_page_info *my_work =3D (struct copy_page_info *)work;
>> +
>> +	copy_page_routine(my_work->to,
>> +					  my_work->from,
>> +					  my_work->chunk_size);
>> +}
>> +
>> +int copy_page_mt(struct page *to, struct page *from, int nr_pages)
>> +{
>> +	unsigned int total_mt_num =3D limit_mt_num;
>> +	int to_node =3D page_to_nid(to);
>
> Should we make sure that the entire page range [to, to + nr_pages] is
> part of to_node.
>

Currently, this is only used for huge pages. nr_pages =3D hpage_nr_pages(=
).
This guarantees the entire page range in the same node.

>> +	int i;
>> +	struct copy_page_info *work_items;
>> +	char *vto, *vfrom;
>> +	unsigned long chunk_size;
>> +	const struct cpumask *per_node_cpumask =3D cpumask_of_node(to_node);=

>
> So all the threads used for copy has to be part of cpumask of the
> destination node ? Why ? The copy accesses both the source pages as
> well as destination pages. Source node threads might also perform
> good for the memory accesses. Which and how many threads should be
> used for copy should be decided wisely from an architecture call
> back. On a NUMA system this will have impact on performance of the
> multi threaded copy.

This is based on my copy throughput benchmark results. The results
shows that moving data from the remote node to the local node (pulling)
has higher throughput than moving data from the local node to the remote =
node (pushing).

I got the same results from both Intel Xeon and IBM Power8, but
it might not be the case for other machines.

Ideally, we can do a boot time benchmark to find out the best configurati=
on,
like pulling or pushing the data, how many threads. But for this
patchset, I may choose pulling the data.


>
>
>> +	int cpu_id_list[32] =3D {0};
>> +	int cpu;
>> +
>> +	total_mt_num =3D min_t(unsigned int, total_mt_num,
>> +						 cpumask_weight(per_node_cpumask));
>> +	total_mt_num =3D (total_mt_num / 2) * 2;
>> +
>> +	work_items =3D kcalloc(total_mt_num, sizeof(struct copy_page_info),
>> +						 GFP_KERNEL);
>> +	if (!work_items)
>> +		return -ENOMEM;
>> +
>> +	i =3D 0;
>> +	for_each_cpu(cpu, per_node_cpumask) {
>> +		if (i >=3D total_mt_num)
>> +			break;
>> +		cpu_id_list[i] =3D cpu;
>> +		++i;
>> +	}
>> +
>> +	vfrom =3D kmap(from);
>> +	vto =3D kmap(to);
>> +	chunk_size =3D PAGE_SIZE*nr_pages / total_mt_num;
>
> Coding style ? Please run all these patches though scripts/
> checkpatch.pl script to catch coding style problems.
>
>> +
>> +	for (i =3D 0; i < total_mt_num; ++i) {
>> +		INIT_WORK((struct work_struct *)&work_items[i],
>> +				  copy_page_work_queue_thread);
>> +
>> +		work_items[i].to =3D vto + i * chunk_size;
>> +		work_items[i].from =3D vfrom + i * chunk_size;
>> +		work_items[i].chunk_size =3D chunk_size;
>> +
>> +		queue_work_on(cpu_id_list[i],
>> +					  system_highpri_wq,
>> +					  (struct work_struct *)&work_items[i]);
>
> I am not very familiar with the system work queues but is
> system_highpri_wq has the highest priority ? Because if
> the time spend waiting on these work queue functions to
> execute increases it can offset out all the benefits we
> get by this multi threaded copy.

According to include/linux/workqueue.h, system_highpri_wq has
high priority.

Another option is to create a dedicated workqueue for all
copy jobs.


--
Best Regards
Yan Zi

--=_MailMate_0D94575F-017E-4199-900C-F5F3A4089F0A_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJYPEdTAAoJEEGLLxGcTqbM7bIH/3ZjU4G61oK8RPyu2zX2/x0f
ELOEGQrlsZAbcIXVelg5mWWL5QtB9aHi0JMUwpPdADrRDNHotS1eRt04zezgjPVG
mGHZCm3NYMK4xJVWoeXridbaS6CrpWjSst9bBbWLxH8KX0Aupr3zEEnxIuiEVQM9
h7f2ZJJNXGwW4nS6uEZcpZEiqCZV2o0liEBpiQmpdiY1QlmfbN/1J6rd5/N4bx99
2rQ3fAIMvCaVV0jFOPnzsznanXPzLiv9YkJhMvM8GK0vc/foEEXLxS1hREtAF76C
YGVlJ08TMdOqb5ZXBjSDhW+NBFD07KpoNrWZ/0JdnGPsO56ZfjwnCgRQ5sCRRVQ=
=6sj7
-----END PGP SIGNATURE-----

--=_MailMate_0D94575F-017E-4199-900C-F5F3A4089F0A_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
