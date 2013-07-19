Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id BD3FF6B0031
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 15:52:04 -0400 (EDT)
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id r6JJq1pO008550
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 19 Jul 2013 21:52:02 +0200
Message-ID: <51E998E0.10207@itwm.fraunhofer.de>
Date: Fri, 19 Jul 2013 21:52:00 +0200
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
MIME-Version: 1.0
Subject: Re: Linux Plumbers IO & File System Micro-conference
References: <51E03AFB.1000000@gmail.com>
In-Reply-To: <51E03AFB.1000000@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Wheeler <ricwheeler@gmail.com>
Cc: linux-mm@kvack.org, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Andreas Dilger <adilger@dilger.ca>, sage@inktank.com

Hello Ric, hi all,

On 07/12/2013 07:20 PM, Ric Wheeler wrote:
>
> If you have topics that you would like to add, wait until the
> instructions get posted at the link above. If you are impatient, feel
> free to email me directly (but probably best to drop the broad mailing
> lists from the reply).

sorry, that will be a rather long introduction, the short conclusion is 
below.


Introduction to the meta-cache issue:
=====================================
For quite a while we are redesigning our FhGFS storage layout to 
workaround meta-cache issues of underlying file systems. However, there 
are constraints as data and meta-data are distributed on between several 
targets/servers. Other distributed file systems, such as Lustre and (I 
think) cepfs should have the similar issues.

So the main issue we have is that streaming reads/writes evict 
meta-pages from the page-cache. I.e. this results in lots of 
directory-block reads on creating files. So FhGFS, Lustre an (I believe) 
cephfs are using hash-directories to store object files. Access to files 
in these hash-directories is rather random and with increasing number of 
files, access to hash directory-blocks/pages also gets entirely random. 
Streaming IO easily evicts these pages, which results in high latencies 
when users perform file creates/deletes, as corresponding directory 
blocks have to be re-read from disk again and again.
Now one could argue that hash-directories are poor choice and indeed we 
are mostly solving that issue in FhGFS now(currently stable release on 
the meta side, upcoming release on the data/storage side).
However, given by the problem of distributed meta-data and distributed 
data we have not found a way yet to entirely eliminate hash directories. 
For example, recently one of our users created 80 million directories 
with one or two files in these directories and even with the new layout 
that still would be an issue. It even is an issue with direct access on 
the underlying file system. Of course,  basically empty directories 
should be avoided at all, but users have their own way of doing IO.
Furthermore, the meta-cache vs. streaming-cache issue is not limited to 
directory blocks only, but any cached meta-data are affected. Mel 
recently wrote a few patches to improve meta-caching ("Obey 
mark_page_accessed hint given by filesystems"), but at least for our 
directory-block issue that doesn't seem to help.

Conclusion:
===========
 From my point of view, there should be a small, but configurable, 
number pages reserved for meta-data only. If streaming IO wouldn't be 
able evict these pages, our and other file systems meta-cache issues 
probably would be entire solved at all.


Example:
========

Just a very basic simple bonnie++ test with 60000 files on ext4 with 
inlined data to reduce block and bitmap lookups and writes.

Entirely cached hash directories (16384), which are populated with about 
16 million files, so 1000 files per hash-dir.

> Version  1.96       ------Sequential Create------ --------Random Create--------
> fslab3              -Create-- --Read--- -Delete-- -Create-- --Read--- -Delete--
> files:max:min        /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP
>            60:32:32  1702  14  2025  12  1332   4  1873  16  2047  13  1266   3
> Latency              3874ms    6645ms    8659ms     505ms    7257ms    9627ms
> 1.96,1.96,fslab3,1,1374655110,,,,,,,,,,,,,,60,32,32,,,1702,14,2025,12,1332,4,1873,16,2047,13,1266,3,,,,,,,3874ms,6645ms,8659ms,505ms,7257ms,9627ms


Now after clients did some streaming IO:

> Version  1.96       ------Sequential Create------ --------Random Create--------
> fslab3              -Create-- --Read--- -Delete-- -Create-- --Read--- -Delete--
> files:max:min        /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP
>            60:32:32   541   4  2343  16  2103   6   586   5  1947  13  1603   4
> Latency               190ms     166ms    3459ms    6762ms    6518ms    9185ms


With longer/more streaming that can go down to 25 creates/s. iostat and 
btrace show lots of meta-reads then, which correspond to directory-block 
reads.

Now after running 'find' over these hash directories to re-read all blocks:

> Version  1.96       ------Sequential Create------ --------Random Create--------
> fslab3              -Create-- --Read--- -Delete-- -Create-- --Read--- -Delete--
> files:max:min        /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP
>            60:32:32  1878  16  2766  16  2464   7  1506  13  2054  13  1433   4
> Latency               349ms     164ms    1594ms    7730ms    6204ms    8112ms



Would a dedicated meta-cache be a topic for discussion?


Thanks,
Bernd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
