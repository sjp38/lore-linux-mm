Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 2CD866B0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 09:16:45 -0500 (EST)
Received: by mail-qc0-f195.google.com with SMTP id x40so687317qcp.6
        for <linux-mm@kvack.org>; Wed, 20 Feb 2013 06:16:44 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 20 Feb 2013 17:16:43 +0300
Message-ID: <CABF3WkkYWvfK8Jv-D=bsHH8GA5HtP4AggANe4EaWJDbmMvDD+w@mail.gmail.com>
Subject: BUG root-caused: careless processing of pagevec causes "Bad page states"
From: Valery Podrezov <pvadop@gmail.com>
Content-Type: multipart/alternative; boundary=047d7bacb8f0916d7104d6289b92
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Valery Podrezov <pvadop@gmail.com>

--047d7bacb8f0916d7104d6289b92
Content-Type: text/plain; charset=ISO-8859-1

SUMMARY: careless processing of pagevec causes "Bad page states"

I have the messages "BUG: Bad page state in process.." in SMP mode with two
cpus (kernel 3.3).
I have root-caused the problem, see description below.
I have prepared the temporary workaround, it helps to eliminate the problem
and demonstrates additionally the essence of the problem.

The following sections are provided below:

    DESCRIPTION
    ENVIRONEMENT
    OOPS-messages
    WORKAROUND

Is it a known issue and is there already the patch properly fixing it?
Feel free to ask me any questions.

Best Regards,
 Valery Podrezov



DESCRIPTION:


There is how the problem is generated
(PFN0 refers the problematical physical page,
(1) and (2) are successive points of execution):

1. cpu 0: ...
   cpu 1: is running the user process (PROC0)
          Gets the new page with the PFN0 from free list by alloc_page_vma()
          Runs page_add_new_anon_rmap(), thus the page PFN0 occurs in
pagevec of this cpu (it is 5-th): pvec = &get_cpu_var(lru_add_pvecs)[lru];
          Runs fork (PROC1 - the generated child process)
          The page PFN0 is present in the page tables of the child process
PROC1 (it is read-only, to be COWed)

2. cpu 0: is running PROC1
          writes to the virtual address (VA1) translated through its page
tables to the PFN0
          do_page_fault (data) on VA1 (physical page is present in the page
tables of the process, but no write permissions)

   cpu 1: is running PROC1
          do_page_fault (data) on some virtual address (no page in page
tables)
          Gets the new page from free list by alloc_page_vma()
          Runs page_add_new_anon_rmap(), then __lru_cache_add()
          This new page is just 14-th in pagevec of this cpu, so runs
__pagevec_lru_add(),
          then pagevec_lru_move_fn() and, finally, __pagevec_lru_add_fn()

There are no common locks at this point applied for both processes
simultaneously,
these locks are applied:
   core 0: PROC0->mm->mmap_sem
           PFN0->flags PG_locked (lock_page)

   core 1: PROC1->mm->mmap_sem (!= PROC0->mm->mmap_sem)
           PFN0->zone->lru_lock

The more detailed timing below of point (2) for both cpus
shows how the bit PG_locked is mistakenly generated for the PFN0.

   Both cpus are processing do_page_fault() (see above)
   Both cpus are in the same routine do_wp_page()

   a) cpu 0: locks the page by trylock_page(old_page) (it is just the page
with PFN0)
   b) cpu 1: is processing __pagevec_lru_add_fn()
             Reads page->flags of its 5-th element of pagevec (it is PFN0
page, it contains PG_locked set to 1, see (a))

   c) cpu 0: unlocks the page by unlock_page(old_page) (reset the bit
PG_locked of PFN0 page)
   d) cpu 1: executes SetPageLRU(page) in __pagevec_lru_add_fn() and thus
sets not only PG_lru
             bit of PFN0 page but, mistakenly, the bit PG_locked too

This leads to "BUG: Bad page state" later while releasing PFN0 page because
of PG_locked bit present in flags of PFN0 page.


ENVIRONMENT:


   Linux kernel-3.3


OOPS-messages:


BUG: Bad page state in process runt_cj.sh  pfn:7fcd9
page:c05f9b20 count:0 mapcount:0 mapping:  (null) index:0xbfffd
page flags: 0x80080009(locked|uptodate|swapbacked)
Modules linked in:

Call Trace:
 [<00000000c1098d78>] dump_page+0x10c/0x120
 [<00000000c1098f50>] bad_page+0x1c4/0x1f4
 [<00000000c1099060>] free_pages_prepare+0xe0/0x10c
 [<00000000c109afd0>] free_hot_cold_page+0x38/0x2c8
 [<00000000c109b538>] free_hot_cold_page_list+0x38/0x64
 [<00000000c10a12f8>] release_pages+0x1e0/0x2cc
 [<00000000c10cdffc>] free_pages_and_swap_cache+0xa4/0x154
 [<00000000c10b49a0>] tlb_flush_mmu+0x98/0xcc
 [<00000000c10b49e4>] tlb_finish_mmu+0x10/0x54
 [<00000000c10c08a0>] exit_mmap+0x11c/0x168
 [<00000000c101988c>] mmput+0x5c/0x164
 [<00000000c10e85c0>] flush_old_exec+0x7d4/0xacc
 [<00000000c114ac24>] load_elf_binary+0x534/0x2514
 [<00000000c11c7158>] __up_read+0x20/0x108
 [<00000000c11cde48>] __va_probe_existent_region+0x164/0x190
 [<00000000c11ce098>] generic_copy_from_user+0xb4/0xd0
 [<00000000c10e7c10>] copy_strings+0x4d8/0x66c
 [<00000000c10e68ec>] search_binary_handler+0x110/0x488
 [<00000000c10e97f0>] do_execve+0x584/0x6a8
 [<00000000c10017c4>] sys_execve+0x38/0x104
 [<00000000c1013aec>] stub_execve+0x14/0x18
 [<00000000c100f1b4>] go_scall+0x30/0x38

Disabling lock debugging due to kernel taint


WORKAROUND:


I don't consider it as a potential patch at least because it doesn't
support properly
the "WARNING, pagevec_add: no space in pvec" conditions, as well, it can
impact performance, etc..
It requires further investigations.
Nevertheless, it helped me temporary not to stick in the problem.

There are the changed things per-files below.

linux-3.3/include/linux/pagevec.h:

/* 14 pointers + two long's align the pagevec structure to a power of two */
// #define PAGEVEC_SIZE    14
#define PAGEVEC_SIZE    (14 + 5*16)

static inline unsigned pagevec_add(struct pagevec *pvec, struct page *page)
{
    if (pvec->nr >= PAGEVEC_SIZE) {
        early_printk("WARNING, pagevec_add: no space in pvec 0x%lx, the
page=0x%lx ????????????????!!!!!!!!!!!!!!!!\n", pvec, page);
        return (0);
    }

    pvec->pages[pvec->nr++] = page;
    return pagevec_space(pvec);
}


linux-3.3/mm/swap.c:


static void pagevec_lru_move_fn(struct pagevec *pvec,
                int (*move_fn)(struct page *page, void *arg),
                void *arg)
{
    int i;
    struct zone *zone = NULL;
    unsigned long flags = 0;

int processed;
struct page *page;
int slots_available = -1;

int not_processed_index = 0;
struct page *not_processed_pages[PAGEVEC_SIZE];

int processed_index = 0;
struct page *processed_pages[PAGEVEC_SIZE];


    for (i = 0; i < pagevec_count(pvec); i++) {
        struct page *page = pvec->pages[i];
        struct zone *pagezone = page_zone(page);

        if (pagezone != zone) {
            if (zone)
                spin_unlock_irqrestore(&zone->lru_lock, flags);
            zone = pagezone;
            spin_lock_irqsave(&zone->lru_lock, flags);
        }

        // (*move_fn)(page, arg);

if (trylock_page(page)) {
    (*move_fn)(page, arg);
    unlock_page(page);
    processed = 1;
} else {
    processed = 0;
}

if (processed) {
    processed_pages[processed_index++] = page;
} else {
    not_processed_pages[not_processed_index++] = page;
}

    }
    if (zone)
        spin_unlock_irqrestore(&zone->lru_lock, flags);

    // release_pages(pvec->pages, pvec->nr, pvec->cold);
if (processed_index) {
    release_pages(processed_pages, processed_index, pvec->cold);
}

    pagevec_reinit(pvec);

if (not_processed_index) {
    for (i = 0; i < not_processed_index; i++) {
        page = not_processed_pages[i];
        slots_available = pagevec_add(pvec, page);
    }
}
}

----<end>

--047d7bacb8f0916d7104d6289b92
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<span style=3D"font-weight:bold">SUMMARY</span>: careless processing of pag=
evec causes &quot;Bad page states&quot;<br>


<br>


I have the messages &quot;BUG: Bad page state in process..&quot; in SMP mod=
e with two cpus (kernel 3.3).<br>


I have <span style=3D"font-weight:bold">root-caused the problem</span>, see=
 description below.<br>


I have <span style=3D"font-weight:bold">prepared the temporary</span> <span=
 style=3D"font-weight:bold">workaround</span>, it helps to eliminate the pr=
oblem and demonstrates additionally the essence of the problem.<br>


<br>


The following sections are provided below:<br>


<br>


=A0=A0=A0 DESCRIPTION<br>


=A0=A0=A0 ENVIRONEMENT<br>


=A0=A0=A0 OOPS-messages<br>


=A0=A0=A0 WORKAROUND<br>


<br>


Is it a known issue and is there already the patch properly fixing it?<br>



Feel free to ask me any questions.<br>


<br>


Best Regards,<br>


=A0Valery Podrezov<br>


<br>


<br>


<br>


<span style=3D"font-weight:bold">DESCRIPTION</span>:<br>


<br>


<br>


There is how the problem is generated<br>


(PFN0 refers the problematical physical page,<br>


(1) and (2) are successive points of execution):<br>


<br>


1. cpu 0: ...<br>


=A0=A0 cpu 1: is running the user process (PROC0)<br>


=A0=A0=A0=A0=A0=A0=A0=A0=A0 Gets the new page with the PFN0 from free list =
by alloc_page_vma()<br>


=A0=A0=A0=A0=A0=A0=A0=A0=A0 Runs page_add_new_anon_rmap(), thus the page PF=
N0 occurs in=20
pagevec of this cpu (it is 5-th): pvec =3D=20
&amp;get_cpu_var(lru_add_pvecs)[lru];<br>


=A0=A0=A0=A0=A0=A0=A0=A0=A0 Runs fork (PROC1 - the generated child process)=
<br>


=A0=A0=A0=A0=A0=A0=A0=A0=A0 The page PFN0 is present in the page tables of =
the child process PROC1 (it is read-only, to be COWed)<br>


<br>


2. cpu 0: is running PROC1<br>


=A0=A0=A0=A0=A0=A0=A0=A0=A0 writes to the virtual address (VA1) translated =
through its page tables to the PFN0<br>


=A0=A0=A0=A0=A0=A0=A0=A0=A0 do_page_fault (data) on VA1 (physical page is p=
resent in the page tables of the process, but no write permissions)<br>


<br>


=A0=A0 cpu 1: is running PROC1<br>


=A0=A0=A0=A0=A0=A0=A0=A0=A0 do_page_fault (data) on some virtual address (n=
o page in page tables)<br>


=A0=A0=A0=A0=A0=A0=A0=A0=A0 Gets the new page from free list by alloc_page_=
vma()<br>


=A0=A0=A0=A0=A0=A0=A0=A0=A0 Runs page_add_new_anon_rmap(), then __lru_cache=
_add()<br>


=A0=A0=A0=A0=A0=A0=A0=A0=A0 This new page is just 14-th in pagevec of this =
cpu, so runs __pagevec_lru_add(),<br>


=A0=A0=A0=A0=A0=A0=A0=A0=A0 then pagevec_lru_move_fn() and, finally, __page=
vec_lru_add_fn()<br>


<br>


There are no common locks at this point applied for both processes simultan=
eously,<br>


these locks are applied: <br>


=A0=A0 core 0: PROC0-&gt;mm-&gt;mmap_sem<br>


=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 PFN0-&gt;flags PG_locked (lock_page)<br>


<br>


=A0=A0 core 1: PROC1-&gt;mm-&gt;mmap_sem (!=3D PROC0-&gt;mm-&gt;mmap_sem)<b=
r>


=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 PFN0-&gt;zone-&gt;lru_lock<br>


<br>


The more detailed timing below of point (2) for both cpus<br>


shows how the bit PG_locked is mistakenly generated for the PFN0.<br>


<br>


=A0=A0 Both cpus are processing do_page_fault() (see above)<br>


=A0=A0 Both cpus are in the same routine do_wp_page()<br>


<br>


=A0=A0 a) cpu 0: locks the page by trylock_page(old_page) (it is just the p=
age with PFN0)<br>


=A0=A0 b) cpu 1: is processing __pagevec_lru_add_fn()<br>


=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 Reads page-&gt;flags of its 5-th eleme=
nt of pagevec (it is PFN0 page, it contains PG_locked set to 1, see (a))<br=
>


<br>


=A0=A0 c) cpu 0: unlocks the page by unlock_page(old_page) (reset the bit P=
G_locked of PFN0 page)<br>


=A0=A0 d) cpu 1: executes SetPageLRU(page) in __pagevec_lru_add_fn() and th=
us sets not only PG_lru<br>


=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 bit of PFN0 page but, mistakenly, the =
bit PG_locked too<br>


<br>


This leads to &quot;BUG: Bad page state&quot; later while releasing PFN0 pa=
ge because of PG_locked bit present in flags of PFN0 page.<br>


<br>


<br>


<span style=3D"font-weight:bold">ENVIRONMENT</span>:<br>


<br>


<br>


=A0=A0 Linux kernel-3.3<br>


<br>


<br>


<span style=3D"font-weight:bold">OOPS-messages</span>:<br>


<br>


<br>


BUG: Bad page state in process runt_cj.sh=A0 pfn:7fcd9<br>


page:c05f9b20 count:0 mapcount:0 mapping:=A0 (null) index:0xbfffd<br>


page flags: 0x80080009(locked|uptodate|swapbacked)<br>


Modules linked in:<br>


<br>


Call Trace:<br>


=A0[&lt;00000000c1098d78&gt;] dump_page+0x10c/0x120<br>


=A0[&lt;00000000c1098f50&gt;] bad_page+0x1c4/0x1f4<br>


=A0[&lt;00000000c1099060&gt;] free_pages_prepare+0xe0/0x10c<br>


=A0[&lt;00000000c109afd0&gt;] free_hot_cold_page+0x38/0x2c8<br>


=A0[&lt;00000000c109b538&gt;] free_hot_cold_page_list+0x38/0x64<br>


=A0[&lt;00000000c10a12f8&gt;] release_pages+0x1e0/0x2cc<br>


=A0[&lt;00000000c10cdffc&gt;] free_pages_and_swap_cache+0xa4/0x154<br>


=A0[&lt;00000000c10b49a0&gt;] tlb_flush_mmu+0x98/0xcc<br>


=A0[&lt;00000000c10b49e4&gt;] tlb_finish_mmu+0x10/0x54<br>


=A0[&lt;00000000c10c08a0&gt;] exit_mmap+0x11c/0x168<br>


=A0[&lt;00000000c101988c&gt;] mmput+0x5c/0x164<br>


=A0[&lt;00000000c10e85c0&gt;] flush_old_exec+0x7d4/0xacc<br>


=A0[&lt;00000000c114ac24&gt;] load_elf_binary+0x534/0x2514<br>


=A0[&lt;00000000c11c7158&gt;] __up_read+0x20/0x108<br>


=A0[&lt;00000000c11cde48&gt;] __va_probe_existent_region+0x164/0x190<br>


=A0[&lt;00000000c11ce098&gt;] generic_copy_from_user+0xb4/0xd0<br>


=A0[&lt;00000000c10e7c10&gt;] copy_strings+0x4d8/0x66c<br>


=A0[&lt;00000000c10e68ec&gt;] search_binary_handler+0x110/0x488<br>


=A0[&lt;00000000c10e97f0&gt;] do_execve+0x584/0x6a8<br>


=A0[&lt;00000000c10017c4&gt;] sys_execve+0x38/0x104<br>


=A0[&lt;00000000c1013aec&gt;] stub_execve+0x14/0x18<br>


=A0[&lt;00000000c100f1b4&gt;] go_scall+0x30/0x38<br>


<br>


Disabling lock debugging due to kernel taint<br>


<br>


<br>


<span style=3D"font-weight:bold">WORKAROUND</span>:<br>


<br>


<br>


I don&#39;t consider it as a potential patch at least because it doesn&#39;=
t support properly<br>


the &quot;WARNING, pagevec_add: no space in pvec&quot; conditions, as well,=
 it can impact performance, etc..<br>


It requires further investigations.<br>


Nevertheless, it helped me temporary not to stick in the problem.<br>


<br>


There are the changed things per-files below.<br>


<br>


linux-3.3/include/linux/pagevec.h:<br>


<br>


/* 14 pointers + two long&#39;s align the pagevec structure to a power of t=
wo */<br>


// #define PAGEVEC_SIZE=A0=A0=A0 14<br>


#define PAGEVEC_SIZE=A0=A0=A0 (14 + 5*16)<br>


<br>


static inline unsigned pagevec_add(struct pagevec *pvec, struct page *page)=
<br>


{<br>


=A0=A0=A0 if (pvec-&gt;nr &gt;=3D PAGEVEC_SIZE) {<br>


=A0=A0=A0 =A0=A0=A0 early_printk(&quot;WARNING, pagevec_add: no space in pv=
ec 0x%lx, the=20
page=3D0x%lx ????????????????!!!!!!!!!!!!!!!!\n&quot;, pvec, page);<br>


=A0=A0=A0 =A0=A0=A0 return (0);<br>


=A0=A0=A0 }<br>


<br>


=A0=A0=A0 pvec-&gt;pages[pvec-&gt;nr++] =3D page;<br>


=A0=A0=A0 return pagevec_space(pvec);<br>


}<br>


<br>


<br>


linux-3.3/mm/swap.c:<br>


<br>


<br>


static void pagevec_lru_move_fn(struct pagevec *pvec,<br>


=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 int (*move_fn)(struct page *page, v=
oid *arg),<br>


=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 void *arg)<br>


{<br>


=A0=A0=A0 int i;<br>


=A0=A0=A0 struct zone *zone =3D NULL;<br>


=A0=A0=A0 unsigned long flags =3D 0;<br>


<br>


int processed;<br>


struct page *page;<br>


int slots_available =3D -1;<br>


<br>


int not_processed_index =3D 0;<br>


struct page *not_processed_pages[PAGEVEC_SIZE];<br>


<br>


int processed_index =3D 0;<br>


struct page *processed_pages[PAGEVEC_SIZE];<br>


<br>


<br>


=A0=A0=A0 for (i =3D 0; i &lt; pagevec_count(pvec); i++) {<br>


=A0=A0=A0 =A0=A0=A0 struct page *page =3D pvec-&gt;pages[i];<br>


=A0=A0=A0 =A0=A0=A0 struct zone *pagezone =3D page_zone(page);<br>


<br>


=A0=A0=A0 =A0=A0=A0 if (pagezone !=3D zone) {<br>


=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 if (zone)<br>


=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 =A0=A0=A0 spin_unlock_irqrestore(&amp;zone-&g=
t;lru_lock, flags);<br>


=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 zone =3D pagezone;<br>


=A0=A0=A0 =A0=A0=A0 =A0=A0=A0 spin_lock_irqsave(&amp;zone-&gt;lru_lock, fla=
gs);<br>


=A0=A0=A0 =A0=A0=A0 }<br>


<br>


=A0=A0=A0 =A0=A0=A0 // (*move_fn)(page, arg);<br>


<br>


if (trylock_page(page)) {<br>


=A0=A0=A0 (*move_fn)(page, arg);<br>


=A0=A0=A0 unlock_page(page);<br>


=A0=A0=A0 processed =3D 1;<br>


} else {<br>


=A0=A0=A0 processed =3D 0;<br>


}<br>


<br>


if (processed) {<br>


=A0=A0=A0 processed_pages[processed_index++] =3D page;<br>


} else {<br>


=A0=A0=A0 not_processed_pages[not_processed_index++] =3D page;<br>


}<br>


<br>


=A0=A0=A0 }<br>


=A0=A0=A0 if (zone)<br>


=A0=A0=A0 =A0=A0=A0 spin_unlock_irqrestore(&amp;zone-&gt;lru_lock, flags);<=
br>


<br>


=A0=A0=A0 // release_pages(pvec-&gt;pages, pvec-&gt;nr, pvec-&gt;cold);<br>


if (processed_index) {<br>


=A0=A0=A0 release_pages(processed_pages, processed_index, pvec-&gt;cold);<b=
r>


}<br>


<br>


=A0=A0=A0 pagevec_reinit(pvec);<br>


<br>


if (not_processed_index) {<br>


=A0=A0=A0 for (i =3D 0; i &lt; not_processed_index; i++) {<br>


=A0=A0=A0 =A0=A0=A0 page =3D not_processed_pages[i];<br>


=A0=A0=A0 =A0=A0=A0 slots_available =3D pagevec_add(pvec, page);<br>


=A0=A0=A0 }<br>


}<br>


}<br>


<br>


----&lt;end&gt;

--047d7bacb8f0916d7104d6289b92--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
