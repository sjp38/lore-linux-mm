Message-ID: <A91A08D00A4FD2119BD500104B55BDF6021A6694@pdbh936a.pdb.siemens.de>
From: "Wichert, Gerhard" <Gerhard.Wichert@pdb.siemens.de>
Subject: AW: [bigmem-patch] 4GB with Linux on IA32
Date: Wed, 18 Aug 1999 10:43:07 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Matthew Wilcox' <Matthew.Wilcox@genedata.com>
Cc: "'linux-kernel@vger.rutgers.edu'" <linux-kernel@vger.rutgers.edu>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


> > -----Ursprungliche Nachricht-----
> > Von: Matthew Wilcox [mailto:Matthew.Wilcox@genedata.com]
> > Gesendet am: Dienstag, 17. August 1999 16:32
> > An: Wichert, Gerhard
> > Cc: linux-kernel@vger.rutgers.edu; linux-mm@kvack.org
> > Betreff: Re: [bigmem-patch] 4GB with Linux on IA32
> > 
> > On Mon, Aug 16, 1999 at 06:29:30PM +0200, Andrea Arcangeli wrote:
> > > Performance degradation:
> > > 
> > > 	Close to zero.

So, here are some additional nubers based on this little worst case bench
from Andrea Arcangeli.

#define SIZE (700*1024*1024)

main()
{
	unsigned long start, stop;
	int i;
	char *buf = (char *)malloc(SIZE);

	if (!buf)
		perror("malloc");

	i = 0;

	__asm__ __volatile__ ("rdtsc" :"=a" (start)::"edx");
	for (; i < SIZE; i += 4096, buf += 4096)
		*(int *)buf = 0;

	__asm__ __volatile__ ("rdtsc" :"=a" (stop)::"edx");

	printf("ticks %ul\n", stop-start);
}

This bench shows the overhead for establishing the temporary kernel mapping
for the bigmem page.

Linux-2.3.13:
run 1
ticks 1313001994l
run 2
ticks 1310999320l
run 3
ticks 1309894069l
run 4
ticks 1313788902l
run 5
ticks 1308360521l

Linux-2.3.13 with bigmem support:
run 1
ticks 1331834802l
run 2
ticks 1332486766l
run 3
ticks 1332231641l
run 4
ticks 1332125591l
run 5
ticks 1333419476l

This shows that we get only approx. 2% overhead in the worst case. In
real-world applications you won't probably see any performance degradation.

Gerhard
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
