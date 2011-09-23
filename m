Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BCC819000BD
	for <linux-mm@kvack.org>; Fri, 23 Sep 2011 04:37:29 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p8N8bRmP031242
	for <linux-mm@kvack.org>; Fri, 23 Sep 2011 01:37:27 -0700
Received: from qyk31 (qyk31.prod.google.com [10.241.83.159])
	by wpaz24.hot.corp.google.com with ESMTP id p8N8bMSh008436
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 23 Sep 2011 01:37:26 -0700
Received: by qyk31 with SMTP id 31so3255012qyk.15
        for <linux-mm@kvack.org>; Fri, 23 Sep 2011 01:37:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110922161448.91a2e2b2.akpm@google.com>
References: <1316230753-8693-1-git-send-email-walken@google.com>
	<1316230753-8693-5-git-send-email-walken@google.com>
	<20110922161448.91a2e2b2.akpm@google.com>
Date: Fri, 23 Sep 2011 01:37:21 -0700
Message-ID: <CANN689G5CmhMVf_-jjwtKpb6P3jp+mxzV5cHz9qOMUK-UE1_DQ@mail.gmail.com>
Subject: Re: [PATCH 4/8] kstaled: minimalistic implementation.
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michael Wolf <mjwolf@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Sep 22, 2011 at 4:14 PM, Andrew Morton <akpm@google.com> wrote:
> nit: please prefer to use identifier "memcg" when referring to a mem_cgro=
up.

OK. Done in my tree, will resend it shortly.

>> + =A0 =A0 cb->fill(cb, "idle_clean", stats.idle_clean * PAGE_SIZE);
>> + =A0 =A0 cb->fill(cb, "idle_dirty_file", stats.idle_dirty_file * PAGE_S=
IZE);
>> + =A0 =A0 cb->fill(cb, "idle_dirty_swap", stats.idle_dirty_swap * PAGE_S=
IZE);
>
> So the user interface has units of bytes. =A0Was that documented
> somewhere? =A0Is it worth bothering with? =A0getpagesize() exists...

This is consistent with existing usage in memory.stat for example. I
think bytes is a good default unit, but I could be convinced to add
_in_bytes to all fields if you think that's needed.

> (Actually, do we have a documentation update for the entire feature?)

Patch 2 in the series augments Documentation/cgroups/memory.txt

>> +static inline void kstaled_scan_page(struct page *page)
>
> uninline this. =A0You may find that the compiler already uninlined it.
> Or it might inline it for you even if it wasn't declared inline. =A0gcc
> does a decent job of optimizing this stuff for us and hints are often
> unneeded.

I tend to manually inline functions that have one single call site.
Some time ago the compilers weren't smart about this, but I suppose
they might have improved. I don't care very strongly either way so
I'll just uninline it as suggested.

>> + =A0 =A0 else if (!trylock_page(page)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* We need to lock the page to dereference t=
he mapping.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* But don't risk sleeping by calling lock_p=
age().
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* We don't want to stall kstaled, so we con=
servatively
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* count locked pages as unreclaimable.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>
> hm. =A0Pages are rarely locked for very long. =A0They aren't locked durin=
g
> writeback. =A0 I question the need for this?

Pages are locked during hard page faults; this is IMO sufficient
reason for the above code.

>> + =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct address_space *mapping =3D page->mappin=
g;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 is_locked =3D true;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* The page is still anon - it has been cont=
inuously referenced
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* since the prior check.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 VM_BUG_ON(PageAnon(page) || mapping !=3D page_=
rmapping(page));
>
> Really? =A0Are you sure that an elevated refcount is sufficient to
> stabilise both of these?

The elevated refcount stabilizes PageAnon().

The mapping is stable only after the page has been locked; note that
page->mapping was read after the page was locked. Essentially I'm
asserting that page_rmapping(page) =3D=3D page->mapping, which is true for
non-anon pages.

>> +static int kstaled(void *dummy)
>> +{
>> + =A0 =A0 while (1) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 int scan_seconds;
>> + =A0 =A0 =A0 =A0 =A0 =A0 int nid;
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct mem_cgroup *mem;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 wait_event_interruptible(kstaled_wait,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(scan_secon=
ds =3D kstaled_scan_seconds) > 0);
>> + =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* We use interruptible wait_event so as not=
 to contribute
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* to the machine load average while we're s=
leeping.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* However, we don't actually expect to rece=
ive a signal
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* since we run as a kernel thread, so the c=
ondition we were
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* waiting for should be true once we get he=
re.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(scan_seconds <=3D 0);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 for_each_mem_cgroup_all(mem)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 memset(&mem->idle_scan_stats, =
0,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0sizeof(mem->idl=
e_scan_stats));
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 for_each_node_state(nid, N_HIGH_MEMORY)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kstaled_scan_node(NODE_DATA(ni=
d));
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 for_each_mem_cgroup_all(mem) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 write_seqcount_begin(&mem->idl=
e_page_stats_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem->idle_page_stats =3D mem->=
idle_scan_stats;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem->idle_page_scans++;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 write_seqcount_end(&mem->idle_=
page_stats_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 schedule_timeout_interruptible(scan_seconds * =
HZ);
>> + =A0 =A0 }
>> +
>> + =A0 =A0 BUG();
>> + =A0 =A0 return 0; =A0 =A0 =A0 /* NOT REACHED */
>> +}
>
> OK, I'm really confused.
>
> Take a minimal machine with a single node which contains one zone.
>
> AFAICT this code will measure the number of idle pages in that zone and
> then will attribute that number into *every* cgroup in the system.
> With no discrimination between them. =A0So it really provided no useful
> information at all.

what happens is that we maintain two sets of stats per cgroup:
- idle_scan_stats is reset to 0 at the start of the scan, its counters
get incremented as we scan the node and find idle pages.
- idle_page_stats is what we export; at the end of a scan the tally
from the same cgroup's idle_scan_stats gets copied into this.

> I was quite surprised to see a physical page scan! =A0I'd have expected
> kstaled to be doing pte tree walks.

We haven't gone that way for two reasons:
- we wanted to find hot and cold file pages as well, even for files
that never get mapped into processes.
- executable files that are run periodically should appear as hot,
even if the executable is not running at the time we happen to scan.

>> +static ssize_t kstaled_scan_seconds_store(struct kobject *kobj,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 struct kobj_attribute *attr,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 const char *buf, size_t count)
>> +{
>> + =A0 =A0 int err;
>> + =A0 =A0 unsigned long input;
>> +
>> + =A0 =A0 err =3D strict_strtoul(buf, 10, &input);
>
> Please use the new kstrto*() interfaces when merging up to mainline.

Done. I wasn't aware of this interface, thanks!

> I wonder if one thread machine-wide will be sufficient. =A0We might end
> up with per-nice threads, for example. =A0Like kswapd.

I can comment on the history there.

In our fakenuma based implementation we started with per-node scanning
threads. However, it turned out that for very large files, two
scanning threads could end up scanning pages that share the same
mapping so that the mapping's i_mmap_mutex would get contended. And
the same problem would also show up with large anon VMA regions and
page_lock_anon_vma(). So, we ended up needing to ensure one thread
would scan all fakenuma nodes assigned to a given cgroup, in order to
avoid performance problems.

With memcg we can't as easily know which pages to scan for a given
cgroup, so we end up with one single thread scanning the entire
memory. It's been working good enough for the memory sized and scan
rates we're interested in so far.

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
