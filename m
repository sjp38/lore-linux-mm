Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C5FDB6B0253
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 18:20:53 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c206so41416583wme.3
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 15:20:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c2si28673870wrc.313.2017.01.25.15.20.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 15:20:52 -0800 (PST)
From: NeilBrown <neilb@suse.com>
Date: Thu, 26 Jan 2017 10:19:31 +1100
Subject: Re: [ATTEND] many topics
In-Reply-To: <58357cf1-65fc-b637-de8e-6cf9c9d91882@suse.cz>
References: <20170118054945.GD18349@bombadil.infradead.org> <20170118133243.GB7021@dhcp22.suse.cz> <20170119110513.GA22816@bombadil.infradead.org> <20170119113317.GO30786@dhcp22.suse.cz> <20170119115243.GB22816@bombadil.infradead.org> <20170119121135.GR30786@dhcp22.suse.cz> <878tq5ff0i.fsf@notabene.neil.brown.name> <20170121131644.zupuk44p5jyzu5c5@thunk.org> <87ziijem9e.fsf@notabene.neil.brown.name> <20170123060544.GA12833@bombadil.infradead.org> <20170123170924.ubx2honzxe7g34on@thunk.org> <87mvehd0ze.fsf@notabene.neil.brown.name> <58357cf1-65fc-b637-de8e-6cf9c9d91882@suse.cz>
Message-ID: <8760l2vibg.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Theodore Ts'o <tytso@mit.edu>, Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Jan 25 2017, Vlastimil Babka wrote:

> On 01/23/2017 08:34 PM, NeilBrown wrote:
>> On Tue, Jan 24 2017, Theodore Ts'o wrote:
>>
>>> On Sun, Jan 22, 2017 at 10:05:44PM -0800, Matthew Wilcox wrote:
>>>>
>>>> I don't have a clear picture in my mind of when Java promotes objects
>>>> from nursery to tenure
>>>
>>> It's typically on the order of minutes.   :-)
>>>
>>>> ... which is not too different from my lack of
>>>> understanding of what the MM layer considers "temporary" :-)  Is it
>>>> acceptable usage to allocate a SCSI command (guaranteed to be freed
>>>> within 30 seconds) from the temporary area?  Or should it only be used
>>>> for allocations where the thread of control is not going to sleep betw=
een
>>>> allocation and freeing?
>>>
>>> What the mm folks have said is that it's to prevent fragmentation.  If
>>> that's the optimization, whether or not you the process is allocating
>>> the memory sleeps for a few hundred milliseconds, or even seconds, is
>>> really in the noise compared with the average lifetime of an inode in
>>> the inode cache, or a page in the page cache....
>>>
>>> Why do you think it matters whether or not we sleep?  I've not heard
>>> any explanation for the assumption for why this might be important.
>>
>> Because "TEMPORARY" implies a limit to the amount of time, and sleeping
>> is the thing that causes a process to take a large amount of time.  It
>> seems like an obvious connection to me.
>
> There's no simple connection to time, it depends on the larger picture - =
what's=20
> the state of the allocator and what other allocations/free's are happenin=
g=20
> around this one. Perhaps let me try to explain what the flag does and wha=
t=20
> benefits are expected.

If there is no simple connection to time, then I would discourage use of
the word "TEMPORARY" as that has a strong connection with the concept of ti=
me.

>
> GFP_TEMPORARY, compared to GFP_KERNEL, adds __GFP_RECLAIMABLE, which trie=
s to=20
> place the allocation within MIGRATE_RECLAIMABLE pageblocks - GFP_KERNEL i=
mplies=20
> MIGRATE_UNMOVABLE pageblocks, and userspace allocations are typically=20
> MIGRATE_MOVABLE. The main goal of this "mobility grouping" is to prevent =
the=20
> unmovable pages spreading all over the memory, making it impossible to ge=
t=20
> larger blocks by defragmentation (compaction). Ideally we would have all =
these=20
> problematic pages fit neatly into the smallest possible number of pageblo=
cks=20
> that can accomodate them. But we can't know in advance how many, and we d=
on't=20
> know their lifetimes, so there are various heuristics for relabeling page=
blocks=20
> between the 3 types as we exceed the existing ones.
>
> Now GFP_TEMPORARY means we tell the allocator about the relatively shorte=
r=20
> lifetime, so it places the allocation within the RECLAIMABLE pageblocks, =
which=20
> are also used for slab caches that have shrinkers. The expected benefit o=
f this=20
> is that we potentially prevent growing the number of UNMOVABLE pageblocks=
=20
> (either directly by this allocation, or a subsequent GFP_KERNEL one, that=
 would=20
> otherwise fit within the existing pageblocks). While the RECLAIMABLE page=
s also=20
> cannot be defragmented (at least currently, there are some proposals for =
the=20
> slab caches...), we can at least shrink them, so the negative impact on=20
> compaction is considered less severe in the longer term.

Hmmm...  this seems like a fuzzy heuristic.
I can use GFP_TEMPORARY as long  I'll free the memory eventually, or
there is some way for you to ask me to free the memory, though I don't
have to succeed - every.

If this heuristic actually works, and reduces fragmentation, then I
suspect it is more luck than good management.  You have maybe added
GFP_TEMPORARY in a few places which fit with your understanding of what
you want and which don't ruin the outcomes in your tests.  But without a
strong definition of when it can and cannot be used, it seems quite
likely that someone else will start using it in a way that fits within
your vague statement of requirements, but actually results in much more
fragmentation.

i.e. I think this is a fragile heuristic and not a long term solution
for anything.

I think it would be better if we could discard the idea of "reclaimable"
and just stick with "movable" and "unmovable".  Lots of things are not
movable at present, but could be made movable with relatively little
effort.  Once the interfaces are in place to allow arbitrary kernel code
to find out when things should be moved, I suspect that a lot of
allocations could become movable.

Before we reach that point, there might be some value in the heuristic
that "reclaimable" is sort-of close to "movable", but I don't think
that heuristic should appear in the public interface.  i.e. just 'or' in
__GFP_RECLAIMABLE where you think it is a good idea, and leave big
comment explaining why, and how it can be removed when we have proper
interfaces for moving things.

Thanks,
NeilBrown


>
>> Imagine I want to allocate a large contiguous region in the
>> ZONE_MOVEABLE region.  I find a mostly free region, so I just need to
>> move those last few pages.  If there is a limit on how long a process
>> can sleep while holding an allocation from ZONE_MOVEABLE, then I know
>> how long, at most, I need to wait before those pages become either free
>> or movable.  If those processes can wait indefinitely, then I might have
>> to wait indefinitely to get this large region.
>
> Yeah so this is not relevant, because GFP_TEMPORARY does not make the all=
ocation=20
> __GFP_MOVABLE, so it still is not allowed to end up within a ZONE_MOVABLE=
 zone.=20
> Unfortunately the issue similar to that you mention does still exist due =
to=20
> uncontrolled pinning of the movable pages, which affects both ZONE_MOVABL=
E and=20
> CMA, but that's another story...
>
>> "temporary" doesn't mean anything without a well defined time limit.
>>
>> But maybe I completely misunderstand.
>
> HTH,
> Vlastimil
>
>> NeilBrown
>>

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliJMoQACgkQOeye3VZi
gbkolhAAj/I8olcDQjr2wRm3YScuQe8jrCi2AXDropVdTohRl+Z3XmPZhyWv5DoR
9oAKxKU+AElGVOuoAFxYfUYElQJ5JzLrI3W4hgTzICnlQK0aRZ+9NlxIo/DICuuU
BcTdzIjx4WH2O7SHHjmjD78+h+4XCIMTeJJcLiXpP+YTgvM4YRjW4jGz8z4s9JUx
Ael5wcUkKlnJKi2Zma0AWJicA/U1Gwni4Z1IfOuoKrzmrBtR+FomT0UnL9lhXZ8Y
xwooxh9vlKt3bcVtA58hJ3dc6RUhow32o8h/whk/KjvciwhP7U0DUodK7azGGn7c
PieETrKn39Q4dXV/hkaqMtkc6ycLmsD58jZdU6CsyOQhL4uY8m3ZWs57NNhggkjV
x3i4S/1ROKW6F6+JrqX+nuXDLc6zqJVREbUhQe+XWe8MeSNw/rMa+uSYhpfS14ZE
mxWT64VPp6h2zLlt6eAC1MtnbeLN9QtOoutGNGbSj5rRoYXRVMadGcHfatdkpb1O
gN+E9v2DswdUvQf5QpWxVjtp0lCUB1cUM0usLdr/0x+w36yOyDPuyg6HhgQ9Tbr6
WYpaORIlvu95X5+26y8pzR4ZJEAucwiEa4rLwYvtqDauZ0gDNyJpVcPo8LOd6XUR
CtFUDpeZ9isnYqbrAPGqs7FayiiMVMcj30Jd9Tbu5ojEa2GeAT8=
=9A8W
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
