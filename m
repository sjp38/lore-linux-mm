Message-ID: <474DDBFF.9020206@am.sony.com>
Date: Wed, 28 Nov 2007 13:22:07 -0800
From: Geoff Levand <geoffrey.levand@am.sony.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] powerpc: add hugepagesz boot-time parameter
References: <474CF68E.1040709@us.ibm.com> <200711280826.46820.arnd@arndb.de>	<20071128161201.GA10916@csn.ul.ie> <200711281730.40907.arnd@arndb.de>
In-Reply-To: <200711281730.40907.arnd@arndb.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Mel Gorman <mel@csn.ul.ie>, linuxppc-dev@ozlabs.org, kniht@linux.vnet.ibm.com, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Arnd Bergmann wrote:
> On Wednesday 28 November 2007, Mel Gorman wrote:
>> On (28/11/07 08:26), Arnd Bergmann didst pronounce:
>> > On Wednesday 28 November 2007, Jon Tollefson wrote:
>> > > This patch adds the hugepagesz boot-time parameter for ppc64 that lets 
>> > > you pick the size for your huge pages.  The choices available are 64K 
>> > > and 16M.  It defaults to 16M (previously the only choice) if nothing or 
>> > > an invalid choice is specified.  Tested 64K huge pages with the 
>> > > libhugetlbfs 1.2 release with its 'make func' and 'make stress' test 
>> > > invocations.
>> > 
>> > How hard would it be to add the 1MB page size that some CPUs support
>> > as well? On systems with small physical memory like the PS3, that
>> > sounds very useful to me.
>> > 
>> 
>> Does the PS3 support 1M pages in hardware? When I last looked, the magic
>> ibm,segment-page-sizes file that described the supported pagesizes was
>> missing from the device tree. In this situation, the default sizes
>> become 4K and 16M because no other ones are advertised.
> 
> I think you can select the page size using a hypercall on the PS3.
> The CPU supports any two of (64k, 1M, 16M) simultaneously.

The PS3's hypervisor allows you to create the lpar's virtual address
space with two page sizes.  I currently have this hard coded to 64K
and 16M.  Within the address space you create memory regions.  I have
the hot-plug memory mapped in as a single region that is hard coded
as 16M pages.

The current HV implementation only allows you to create an htab of
at maximum 1M, so that influences how you can configure page sizes.

Just as a note, since the amount of memory available to the Linux lpar
is not a multiple of 16M, some of the available hot-plug memory is not
mapped into the address space.  For firmware 1.90, 8M is unused.  I
was thinking to create another region for that memory and put things
like the storage bounce buffers in there.  Maybe I'll use 1M pages
for that memory.

-Geoff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
