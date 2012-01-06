Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id F403E6B0071
	for <linux-mm@kvack.org>; Fri,  6 Jan 2012 12:45:18 -0500 (EST)
Received: by eekc41 with SMTP id c41so1440166eek.14
        for <linux-mm@kvack.org>; Fri, 06 Jan 2012 09:45:17 -0800 (PST)
Message-ID: <4F073325.6040309@openvz.org>
Date: Fri, 06 Jan 2012 21:45:09 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: adjust rss counters for migration entiries
References: <20120106173827.11700.74305.stgit@zurg> <20120106173856.11700.98858.stgit@zurg>
In-Reply-To: <20120106173856.11700.98858.stgit@zurg>
Content-Type: multipart/mixed;
 boundary="------------000809080609070307030202"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

This is a multi-part message in MIME format.
--------------000809080609070307030202
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

This bug can be easily triggered by test-tool in attachment.
I run it with with this arguments: ./mm-thp-torture 100 100

--------------000809080609070307030202
Content-Type: text/x-csrc;
 name="mm-thp-torture.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="mm-thp-torture.c"

/*
 * torture-test for transparent huge pages,
 * memory migration and memory compaction =)
 *
 * usage: ./mm-thp-tortire <threads> <pages>
 *
 * to eat all avaliable huge pages:
 * threads * pages >= ram[mb] / 2[mb]
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <sys/mman.h>


#define PAGE_SIZE (4096)
#define HPAGE_SIZE (4096*512)

int main(int argc, char **argv)
{
	long pages, threads;
	char *buf, *ptr;

	if (argc < 3)
		return 2;

	signal(SIGCHLD, SIG_IGN);

	threads = atol(argv[1]);
	pages = atol(argv[2]);

	buf = mmap(NULL, (pages + 1) * HPAGE_SIZE, PROT_READ|PROT_WRITE,
			MAP_PRIVATE|MAP_ANONYMOUS|MAP_NORESERVE, -1, 0);
	if (buf == MAP_FAILED)
		return 3;

	buf += HPAGE_SIZE - ((long)buf & (HPAGE_SIZE-1));

	while (--threads > 0 && !fork());

	while (1) {
		for ( ptr = buf ; ptr < buf + pages * HPAGE_SIZE ;
				ptr += HPAGE_SIZE ) {
			if (mmap(ptr, HPAGE_SIZE, PROT_READ|PROT_WRITE,
			    MAP_PRIVATE|MAP_ANONYMOUS|MAP_NORESERVE|MAP_FIXED,
			    -1, 0) != ptr)
				return 4;
			*ptr = 0;
			munmap(ptr + PAGE_SIZE, HPAGE_SIZE - PAGE_SIZE);
		}
		if (!fork())
			exit(0);
		munmap(buf, pages * HPAGE_SIZE);
	}
	return 0;
}

--------------000809080609070307030202--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
