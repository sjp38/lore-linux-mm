Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id D7D62900002
	for <linux-mm@kvack.org>; Tue,  6 May 2014 06:29:38 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id hi2so2630624wib.4
        for <linux-mm@kvack.org>; Tue, 06 May 2014 03:29:38 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id va7si5503717wjc.33.2014.05.06.03.29.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 May 2014 03:29:36 -0700 (PDT)
Date: Tue, 6 May 2014 12:29:25 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC] Heterogeneous memory management (mirror process address
 space on a device mmu).
Message-ID: <20140506102925.GD11096@twins.programming.kicks-ass.net>
References: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="fDERRRNgB4on1jOB"
Content-Disposition: inline
In-Reply-To: <1399038730-25641-1-git-send-email-j.glisse@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: j.glisse@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Linda Wang <lwang@redhat.com>, Kevin E Martin <kem@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Jeff Law <law@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, "Sander, Ben" <ben.sander@amd.com>, "Stoner, Greg" <Greg.Stoner@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>, "Mantor, Michael" <Michael.Mantor@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, "Morichetti, Laurent" <Laurent.Morichetti@amd.com>, "Deucher, Alexander" <Alexander.Deucher@amd.com>, "Gabbay, Oded" <Oded.Gabbay@amd.com>, Linus Torvalds <torvalds@linux-foundation.org>, Davidlohr Bueso <davidlohr@hp.com>


--fDERRRNgB4on1jOB
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


So you forgot to CC Linus, Linus has expressed some dislike for
preemptible mmu_notifiers in the recent past:

  https://lkml.org/lkml/2013/9/30/385

And here you're proposing to add dependencies on it.

Left the original msg in tact for the new Cc's.

On Fri, May 02, 2014 at 09:51:59AM -0400, j.glisse@gmail.com wrote:
> In a nutshell:
>=20
> The heterogeneous memory management (hmm) patchset implement a new api th=
at
> sit on top of the mmu notifier api. It provides a simple api to device dr=
iver
> to mirror a process address space without having to lock or take referenc=
e on
> page and block them from being reclam or migrated. Any changes on a proce=
ss
> address space is mirrored to the device page table by the hmm code. To ac=
hieve
> this not only we need each driver to implement a set of callback function=
s but
> hmm also interface itself in many key location of the mm code and fs code.
> Moreover hmm allow to migrate range of memory to the device remote memory=
 to
> take advantages of its lower latency and higher bandwidth.
>=20
> The why:
>=20
> We want to be able to mirror a process address space so that compute api =
such
> as OpenCL or other similar api can start using the exact same address spa=
ce on
> the GPU as on the CPU. This will greatly simplify usages of those api. Mo=
reover
> we believe that we will see more and more specialize unit functions that =
will
> want to mirror process address using their own mmu.
>=20
> To achieve this hmm requires :
>  A.1 - Hardware requirements
>  A.2 - sleeping inside mmu_notifier
>  A.3 - context information for mmu_notifier callback (patch 1 and 2)
>  A.4 - new helper function for memcg (patch 5)
>  A.5 - special swap type and fault handling code
>  A.6 - file backed memory and filesystem changes
>  A.7 - The write back expectation
>=20
> While avoiding :
>  B.1 - No new page flag
>  B.2 - No special page reclamation code
>=20
> Finally the rest of this email deals with :
>  C.1 - Alternative designs
>  C.2 - Hardware solution
>  C.3 - Routines marked EXPORT_SYMBOL
>  C.4 - Planned features
>  C.5 - Getting upstream
>=20
> But first patchlist :
>=20
>  0001 - Clarify the use of TTU_UNMAP as being done for VMSCAN or POISONING
>  0002 - Give context information to mmu_notifier callback ie why the call=
back
>         is made for (because of munmap call, or page migration, ...).
>  0003 - Provide the vma for which the invalidation is happening to mmu_no=
tifier
>         callback. This is mostly and optimization to avoid looking up aga=
in the
>         vma inside the mmu_notifier callback.
>  0004 - Add new helper to the generic interval tree (which use rb tree).
>  0005 - Add new helper to memcg so that anonymous page can be accounted a=
s well
>         as unaccounted without a page struct. Also add a new helper funct=
ion to
>         transfer a charge to a page (charge which have been accounted wit=
hout a
>         struct page in the first place).
>  0006 - Introduce the hmm basic code to support simple device mirroring o=
f the
>         address space. It is fully functional modulo some missing bit (gu=
ard or
>         huge page and few other small corner cases).
>  0007 - Introduce support for migrating anonymous memory to device memory=
=2E This
>         involve introducing a new special swap type and teach the mm page=
 fault
>         code about hmm.
>  0008 - Introduce support for migrating shared or private memory that is =
backed
>         by a file. This is way more complex than anonymous case as it nee=
ds to
>         synchronize with and exclude other kernel code path that might tr=
y to
>         access those pages.
>  0009 - Add hmm support to ext4 filesystem.
>  0010 - Introduce a simple dummy driver that showcase use of the hmm api.
>  0011 - Add support for remote memory to the dummy driver.
>=20
> I believe that patch 1, 2, 3 are use full on their own as they could help=
 fix
> some kvm issues (see https://lkml.org/lkml/2014/1/15/125) and they do not
> modify behavior of any current code (except that patch 3 might result in a
> larger number of call to mmu_notifier as many as there is different vma f=
or
> a range).
>=20
> Other patches have many rough edges but we would like to validate our des=
ign
> and see what we need to change before smoothing out any of them.
>=20
>=20
> A.1 - Hardware requirements :
>=20
> The hardware must have its own mmu with a page table per process it wants=
 to
> mirror. The device mmu mandatory features are :
>   - per page read only flag.
>   - page fault support that stop/suspend hardware thread and support resu=
ming
>     those hardware thread once the page fault have been serviced.
>   - same number of bits for the virtual address as the target architectur=
e (for
>     instance 48 bits on current AMD 64).
>=20
> Advanced optional features :
>   - per page dirty bit (indicating the hardware did write to the page).
>   - per page access bit (indicating the hardware did access the page).
>=20
>=20
> A.2 - Sleeping in mmu notifier callback :
>=20
> Because update device mmu might need to sleep, either for taking device d=
river
> lock (which might be consider fixable) or simply because invalidating the=
 mmu
> might take several hundred millisecond and might involve allocating devic=
e or
> driver resources to perform the operation any of which might require to s=
leep.
>=20
> Thus we need to be able to sleep inside mmu_notifier_invalidate_range_sta=
rt at
> the very least. Also we need to call to mmu_notifier_change_pte to be bra=
cketed
> by mmu_notifier_invalidate_range_start and mmu_notifier_invalidate_range_=
end.
> We need this because mmu_notifier_change_pte is call with the anon vma lo=
ck
> held (and this is a non sleepable lock).
>=20
>=20
> A.3 - Context information for mmu_notifier callback :
>=20
> There is a need to provide more context information on why a mmu_notifier=
 call
> back does happen. Was it because userspace call munmap ? Or was it becaus=
e the
> kernel is trying to free some memory ? Or because page is being migrated ?
>=20
> The context is provided by using unique enum value associated with call s=
ite of
> mmu_notifier functions. The patch here just add the enum value and modify=
 each
> call site to pass along the proper value.
>=20
> The context information is important for management of the secondary mmu.=
 For
> instance on a munmap the device driver will want to free all resources us=
ed by
> that range (device page table memory). This could as well solve the issue=
 that
> was discussed in this thread https://lkml.org/lkml/2014/1/15/125 kvm can =
ignore
> mmu_notifier_invalidate_range based on the enum value.
>=20
>=20
> A.4 - New helper function for memcg :
>=20
> To keep memory control working as expect with the introduction of remote =
memory
> we need to add new helper function so we can account anonymous remote mem=
ory as
> if it was backed by a page. We also need to be able to transfer charge fr=
om the
> remote memory to pages and we need to be able clear a page cgroup without=
 side
> effect to the memcg.
>=20
> The patchset currently does add a new type of memory resource but instead=
 just
> account remote memory as local memory (struct page) is. This is done with=
 the
> minimum amount of change to the memcg code. I believe they are correct.
>=20
> It might make sense to introduce a new sub-type of memory down the road s=
o that
> device memory can be included inside the memcg accounting but we choose t=
o not
> do so at first.
>=20
>=20
> A.5 - Special swap type and fault handling code :
>=20
> When some range of address is backed by device memory we need cpu fault t=
o be
> aware of that so it can ask hmm to trigger migration back to local memory=
=2E To
> avoid too much code disruption we do so by adding a new special hmm swap =
type
> that is special cased in various place inside the mm page fault code. Ref=
er to
> patch 7 for details.
>=20
>=20
> A.6 - File backed memory and filesystem changes :
>=20
> Using remote memory for range of address backed by a file is more complex=
 than
> anonymous memory. There are lot more code path that might want to access =
pages
> that cache a file (for read, write, splice, ...). To avoid disrupting the=
 code
> too much and sleeping inside page cache look up we decided to add hmm sup=
port
> on a per filesystem basis. So each filesystem can be teach about hmm and =
how to
> interact with it correctly.
>=20
> The design is relatively simple, the radix tree is updated to use special=
 hmm
> swap entry for any page which is in remote memory. Thus any radix tree lo=
ok up
> will find the special entry and will know it needs to synchronize itself =
with
> hmm to access the file.
>=20
> There is however subtleties. Updating the radix tree does not guarantee t=
hat
> hmm is the sole user of the page, another kernel/user thread might have d=
one a
> radix look up before the radix tree update.
>=20
> The solution to this issue is to first update the radix tree, then lock e=
ach
> page we are migrating, then unmap it from all the process using it and se=
tting
> its mapping field to NULL so that once we unlock the page all existing co=
de
> will thought that the page was either truncated or reclaimed in both case=
s all
> existing kernel code path will eith perform new look and see the hmm spec=
ial
> entry or will just skip the page. Those code path were audited to insure =
that
> their behavior and expected result are not modified by this.
>=20
> However this does not insure us exclusive access to the page. So at first=
 when
> migrating such page to remote memory we map it read only inside the devic=
e and
> keep the page around so that both the device copy and the page copy conta=
in the
> same data. If the device wishes to write to this remote memory then it ca=
ll hmm
> fault code.
>=20
> To allow write on remote memory hmm will try to free the page, if the pag=
e can
> be free then it means hmm is the unique user of the page and the remote m=
emory
> can safely be written to. If not then this means that the page content mi=
ght
> still be in use by some other process and the device driver have to choos=
e to
> either wait or use the local memory instead. So local memory page are kep=
t as
> long as there are other user for them. We likely need to hookup some spec=
ial
> page reclamation code to force reclaiming those pages after a while.
>=20
>=20
> A.7 - The write back expectation :
>=20
> We also wanted to preserve the writeback and dirty balancing as we believ=
e this
> is an important behavior (avoiding dirty content to stay for too long ins=
ide
> remote memory without being write back to disk). To avoid constantly migr=
ating
> memory back and forth we decided to use existing page (hmm keep all share=
d page
> around and never free them for the lifetime of rmem object they are assoc=
iated
> with) as temporary writeback source. On writeback the remote memory is ma=
pped
> read only on the device and copied back to local memory which is use as s=
ource
> for the disk write.
>=20
> This design choice can however be seen as counter productive as it means =
that
> the device using hmm will see its rmem map read only for writeback and th=
en
> will have to wait for writeback to go through. Another choice would be to
> forget writeback while memory is on the device and pretend page are clear=
 but
> this would break fsync and similar API for file that does have part of its
> content inside some device memory.
>=20
> Middle ground might be to keep fsync and alike working but to ignore any =
other
> writeback.
>=20
>=20
> B.1 - No new page flag :
>=20
> While adding a new page flag would certainly help to find a different des=
ign to
> implement the hmm feature set. We tried to only think about design that d=
o not
> require such a new flag.
>=20
>=20
> B.2 - No special page reclamation code :
>=20
> This is one of the big issue, should be isolate pages that are actively u=
se
> by a device from the regular lru to a specific lru managed by the hmm cod=
e.
> In this patchset we decided to avoid doing so as it would just add comple=
xity
> to already complex code.
>=20
> Current code will trigger sleep inside vmscan when trying to reclaim page=
 that
> belong to a process which is mirrored on a device. Is this acceptable or =
should
> we add a new hmm lru list that would handle all pages used by device in s=
pecial
> way so that those pages are isolated from the regular page reclamation co=
de.
>=20
>=20
> C.1 - Alternative designs :
>=20
> The current design is the one we believe provide enough ground to support=
 all
> necessary features while keeping complexity as low as possible. However i=
 think
> it is important to state that several others designs were tested and to e=
xplain
> why they were discarded.
>=20
> D1) One of the first design introduced a secondary page table directly up=
dated
>   by hmm helper functions. Hope was that this secondary page table could =
be in
>   some way directly use by the device. That was naive ... to say the leas=
t.
>=20
> D2) The secondary page table with hmm specific format, was another design=
 that
>   we tested. In this one the secondary page table was not intended to be =
use by
>   the device but was intended to serve as a buffer btw the cpu page table=
 and
>   the device page table. Update to the device page table would use the hm=
m page
>   table.
>=20
>   While this secondary page table allow to track what is actively use and=
 also
>   gather statistics about it. It does require memory, in worst case as mu=
ch as
>   the cpu page table.
>=20
>   Another issue is that synchronization between cpu update and device try=
ing to
>   access this secondary page table was either prone to lock contention. O=
r was
>   getting awfully complex to avoid locking all while duplicating complexi=
ty
>   inside each of the device driver.
>=20
>   The killing bullet was however the fact that the code was littered with=
 bug
>   condition about discrepancy between the cpu and the hmm page table.
>=20
> D3) Use a structure to track all actively mirrored range per process and =
per
>   device. This allow to have an exact view of which range of memory is in=
 use
>   by which device.
>=20
>   Again this need a lot of memory to track each of the active range and w=
orst
>   case would need more memory than a secondary page table (one struct ran=
ge per
>   page).
>=20
>   Issue here was with the complexity or merging and splitting range on ad=
dress
>   space changes.
>=20
> D4) Use a structure to track all active mirrored range per process (share=
d by
>   all the devices that mirror the same process). This partially address t=
he
>   memory requirement of D3 but this leave the complexity of range merging=
 and
>   splitting intact.
>=20
> The current design is a simplification of D4 in which we only track range=
 of
> memory for memory that have been migrated to device memory. So for any ot=
hers
> operations hmm directly access the cpu page table and forward the appropr=
iate
> information to the device driver through the hmm api. We might need to go=
 back
> to D4 design or a variation of it for some of the features we want add.
>=20
>=20
> C.2 - Hardware solution :
>=20
> What hmm try to achieve can be partially achieved using hardware solution=
=2E Such
> hardware solution is part of PCIE specification with the PASID (process a=
ddress
> space id) and ATS (address translation service). With both of this PCIE f=
eature
> a device can ask for a virtual address of a given process to be translate=
d into
> its corresponding physical address. To achieve this the IOMMU bridge is c=
apable
> of understanding and walking the cpu page table of a process. See the IOM=
MUv2
> implementation inside the linux kernel for reference.
>=20
> There is two huge restriction with hardware solution to this problem. Fir=
st an
> obvious one is that you need hardware support. While HMM also require har=
dware
> support on the GPU side it does not on the architecture side (no requirem=
ent on
> IOMMU, or any bridges that are between the GPU and the system memory). Th=
is is
> a strong advantages to HMM it only require hardware support to one specif=
ic
> part.
>=20
> The second restriction is that hardware solution like IOMMUv2 does not pe=
rmit
> migrating chunk of memory to the device local memory which means under-us=
ing
> hardware resources (all discrete GPU comes with fast local memory that can
> have more than ten times the bandwidth of system memory).
>=20
> This two reasons alone, are we believe enough to justify hmm usefulness.
>=20
> Moreover hmm can work in a hybrid solution where non migrated chunk of me=
mory
> goes through the hardware solution (IOMMUv2 for instance) and only the me=
mory
> that is migrated to the device is handled by the hmm code. The requiremen=
t for
> the hardware is minimal, the hardware need to support the PASID & ATS (or=
 any
> other hardware implementation of the same idea) on page granularity basis=
 (it
> could be on the granularity of any level of the device page table so no n=
eed
> to populate all levels of the device page table). Which is the best solut=
ion
> for the problem.
>=20
>=20
> C.3 - Routines marked EXPORT_SYMBOL
>=20
> As these routines are intended to be referenced in device drivers, they
> are marked EXPORT_SYMBOL as is common practice. This encourages adoption
> of HMM in both GPL and non-GPL drivers, and allows ongoing collaboration
> with one of the primary authors of this idea.
>=20
> I think it would be beneficial to include this feature as soon as possibl=
e.
> Early collaborators can go to the trouble of fixing and polishing the HMM
> implementation, allowing it to fully bake by the time other drivers start
> implementing features requiring it. We are confident that this API will be
> useful to others as they catch up with supporting hardware.
>=20
>=20
> C.4 - Planned features :
>=20
> We are planning to add various features down the road once we can clear t=
he
> basic design. Most important ones are :
>   - Allowing inter-device migration for compatible devices.
>   - Allowing hmm_rmem without backing storage (simplify some of the drive=
r).
>   - Device specific memcg.
>   - Improvement to allow APU to take advantages of rmem, by hiding the pa=
ge
>     from the cpu the gpu can use a different memory controller link that =
do
>     not require cache coherency with the cpu and thus provide higher band=
width.
>   - Atomic device memory operation by unmapping on the cpu while the devi=
ce is
>     performing atomic operation (this require hardware mmu to differentia=
te
>     between regular memory access and atomic memory access and to have a =
flag
>     that allow atomic memory access on per page basis).
>   - Pining private memory to rmem this would be a useful feature to add a=
nd
>     would require addition of a new flag to madvise. Any cpu access would
>     result in SIGBUS for the cpu process.
>=20
>=20
> C.5 - Getting upstream :
>=20
> So what should i do to get this patchset in a mergeable form at least at =
first
> as a staging feature ? Right now the patchset has few rough edges around =
huge
> page support and other smaller issues. But as said above i believe that p=
atch
> 1, 2, 3 and 4 can be merge as is as they do not modify current behavior w=
hile
> being useful to other.
>=20
> Should i implement some secondary hmm specific lru and their associated w=
orker
> thread to avoid having the regular reclaim code to end up sleeping waitin=
g for
> a device to update its page table ?
>=20
> Should i go for a totaly different design ? If so what direction ? As sta=
ted
> above we explored other design and i listed there flaws.
>=20
> Any others things that i need to fix/address/change/improve ?
>=20
> Comments and flames are welcome.
>=20
> Cheers,
> J=E9r=F4me Glisse
>=20
> To: <linux-kernel@vger.kernel.org>,
> To: linux-mm <linux-mm@kvack.org>,
> To: <linux-fsdevel@vger.kernel.org>,
> Cc: "Mel Gorman" <mgorman@suse.de>,
> Cc: "H. Peter Anvin" <hpa@zytor.com>,
> Cc: "Peter Zijlstra" <peterz@infradead.org>,
> Cc: "Andrew Morton" <akpm@linux-foundation.org>,
> Cc: "Linda Wang" <lwang@redhat.com>,
> Cc: "Kevin E Martin" <kem@redhat.com>,
> Cc: "Jerome Glisse" <jglisse@redhat.com>,
> Cc: "Andrea Arcangeli" <aarcange@redhat.com>,
> Cc: "Johannes Weiner" <jweiner@redhat.com>,
> Cc: "Larry Woodman" <lwoodman@redhat.com>,
> Cc: "Rik van Riel" <riel@redhat.com>,
> Cc: "Dave Airlie" <airlied@redhat.com>,
> Cc: "Jeff Law" <law@redhat.com>,
> Cc: "Brendan Conoboy" <blc@redhat.com>,
> Cc: "Joe Donohue" <jdonohue@redhat.com>,
> Cc: "Duncan Poole" <dpoole@nvidia.com>,
> Cc: "Sherry Cheung" <SCheung@nvidia.com>,
> Cc: "Subhash Gutti" <sgutti@nvidia.com>,
> Cc: "John Hubbard" <jhubbard@nvidia.com>,
> Cc: "Mark Hairgrove" <mhairgrove@nvidia.com>,
> Cc: "Lucien Dunning" <ldunning@nvidia.com>,
> Cc: "Cameron Buschardt" <cabuschardt@nvidia.com>,
> Cc: "Arvind Gopalakrishnan" <arvindg@nvidia.com>,
> Cc: "Haggai Eran" <haggaie@mellanox.com>,
> Cc: "Or Gerlitz" <ogerlitz@mellanox.com>,
> Cc: "Sagi Grimberg" <sagig@mellanox.com>
> Cc: "Shachar Raindel" <raindel@mellanox.com>,
> Cc: "Liran Liss" <liranl@mellanox.com>,
> Cc: "Roland Dreier" <roland@purestorage.com>,
> Cc: "Sander, Ben" <ben.sander@amd.com>,
> Cc: "Stoner, Greg" <Greg.Stoner@amd.com>,
> Cc: "Bridgman, John" <John.Bridgman@amd.com>,
> Cc: "Mantor, Michael" <Michael.Mantor@amd.com>,
> Cc: "Blinzer, Paul" <Paul.Blinzer@amd.com>,
> Cc: "Morichetti, Laurent" <Laurent.Morichetti@amd.com>,
> Cc: "Deucher, Alexander" <Alexander.Deucher@amd.com>,
> Cc: "Gabbay, Oded" <Oded.Gabbay@amd.com>,
>=20

--fDERRRNgB4on1jOB
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJTaLmAAAoJEHZH4aRLwOS6ZyYP/j5jnBgUO9/uxuE3ap4ET6yp
Q8BQtn01GErjrqZzI4lcveKtMRCOrdONRGnDTuDkj8xLRu/IDMGJmOZhpXT7QoKu
Nt5P/aENIME2UdeqAq3yNG/oQ0U2lGeOwxxp++JtTw0M4aI8H8lTf+nZ8Hu+kmOj
ILd6Op3esPexsvgdUa0Luly5N4+gfaFGUUSOXP/Hm5GTy6npNTH6hcVtD7PQzOTb
w7848KlAkoE9MzSUHq5RfkOphopZ1de2moloSmImzuGLb4SHekGt9DthKYDmCzHI
+z0UYdR3jwEBynEPQMbpUstmYALIF+CjejfBq2ZIEDJrccWNrhZUU/BkzZMf7B9I
x0NqzZQv+HQ1JpZ9gBeuKdaB93TJPB9ej4NGVXMofChjR4qCRPHb2f1mT7xmuQwp
7k7Vg4TG9IMTt1ZX1kksd/QlWut9JHnNjhZy4ZBx5VV1e0f4FL404c6b4XxyPZfA
0+Adapa6A6q4zh5tnSE3HDRqypdvPXlooSQz7+oPTS1Pk4BePiZBHDO9ltTmMtT7
/ofE+383fcu+6RTjc4nX9oV8a6TOG/NVnPi2WsqxRD57v/+0+MDv4o4B0CoI2ve8
Vdnz6P7MNC7Pz4Q05Qbo9EvsXSHz50RrilICtzB258fCW7r0JXyjHcNlrSBJNIWi
M/MtFwL1Ze1KihR6/Z3c
=8anU
-----END PGP SIGNATURE-----

--fDERRRNgB4on1jOB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
