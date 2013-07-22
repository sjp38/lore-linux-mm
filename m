Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id BB63D6B0032
	for <linux-mm@kvack.org>; Sun, 21 Jul 2013 20:47:52 -0400 (EDT)
Date: Mon, 22 Jul 2013 10:47:41 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Linux Plumbers IO & File System Micro-conference
Message-ID: <20130722004741.GC11674@dastard>
References: <51E03AFB.1000000@gmail.com>
 <51E998E0.10207@itwm.fraunhofer.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51E998E0.10207@itwm.fraunhofer.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: Ric Wheeler <ricwheeler@gmail.com>, linux-mm@kvack.org, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Andreas Dilger <adilger@dilger.ca>, sage@inktank.com

On Fri, Jul 19, 2013 at 09:52:00PM +0200, Bernd Schubert wrote:
> Hello Ric, hi all,
> 
> On 07/12/2013 07:20 PM, Ric Wheeler wrote:
> >
> >If you have topics that you would like to add, wait until the
> >instructions get posted at the link above. If you are impatient, feel
> >free to email me directly (but probably best to drop the broad mailing
> >lists from the reply).
> 
> sorry, that will be a rather long introduction, the short conclusion
> is below.
> 
> 
> Introduction to the meta-cache issue:
> =====================================
> For quite a while we are redesigning our FhGFS storage layout to
> workaround meta-cache issues of underlying file systems. However,
> there are constraints as data and meta-data are distributed on
> between several targets/servers. Other distributed file systems,
> such as Lustre and (I think) cepfs should have the similar issues.
> 
> So the main issue we have is that streaming reads/writes evict
> meta-pages from the page-cache. I.e. this results in lots of
> directory-block reads on creating files. So FhGFS, Lustre an (I
> believe) cephfs are using hash-directories to store object files.
> Access to files in these hash-directories is rather random and with
> increasing number of files, access to hash directory-blocks/pages
> also gets entirely random. Streaming IO easily evicts these pages,
> which results in high latencies when users perform file
> creates/deletes, as corresponding directory blocks have to be
> re-read from disk again and again.

Sounds like a filesystem specific problem. Different filesystems
have different ways of caching metadata and respond differently to
page cache pressure.

For example, we changed XFS to have it's own metdata buffer cache
reclaim mechanisms driven by a shrinker that uses prioritised cache
reclaim to ensure we reclaim less important metadata buffers before
ones that are more frequently hit (e.g. to reclaim tree leaves
before nodes and roots). This was done because the page cache based
reclaim of metadata was completely inadequate (i.e. mostly random!)
and would frequently reclaim the wrong thing and cause performance
under memory pressure to tank....

> From my point of view, there should be a small, but configurable,
> number pages reserved for meta-data only. If streaming IO wouldn't
> be able evict these pages, our and other file systems meta-cache
> issues probably would be entire solved at all.

That's effectively what XFS does automatically - it doesn't reserve
pages, but it holds onto the frequently hit metadata buffers much,
much harder than any other Linux filesystem....

> Example:
> ========
> 
> Just a very basic simple bonnie++ test with 60000 files on ext4 with
> inlined data to reduce block and bitmap lookups and writes.
> 
> Entirely cached hash directories (16384), which are populated with
> about 16 million files, so 1000 files per hash-dir.
> 
> >Version  1.96       ------Sequential Create------ --------Random Create--------
> >fslab3              -Create-- --Read--- -Delete-- -Create-- --Read--- -Delete--
> >files:max:min        /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP
> >           60:32:32  1702  14  2025  12  1332   4  1873  16  2047  13  1266   3
> >Latency              3874ms    6645ms    8659ms     505ms    7257ms    9627ms
> >1.96,1.96,fslab3,1,1374655110,,,,,,,,,,,,,,60,32,32,,,1702,14,2025,12,1332,4,1873,16,2047,13,1266,3,,,,,,,3874ms,6645ms,8659ms,505ms,7257ms,9627ms

Command line parameters, details of storage, the scripts you are
running, etc please. RAM as well, as 16 million files are going to
require at least 20GB RAM to fully cache...

Numbers without context or with "handwavy context" are meaningless
for the purpose of analysis and understanding.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
