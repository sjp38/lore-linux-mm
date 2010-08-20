Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 053E76B02CE
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 02:09:12 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7K69Aiu025703
	for <linux-mm@kvack.org> (envelope-from iram.shahzad@jp.fujitsu.com);
	Fri, 20 Aug 2010 15:09:10 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 007D445DE56
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 15:09:10 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id AD8EB45DE4F
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 15:09:09 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 61A1AE18002
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 15:09:09 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 09DF81DB8038
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 15:09:09 +0900 (JST)
Message-ID: <F185F1F1FF284307ABD7BA74DB4747D1@rainbow>
From: "Iram Shahzad" <iram.shahzad@jp.fujitsu.com>
References: <325E0A25FE724BA18190186F058FF37E@rainbow> <20100817111018.GQ19797@csn.ul.ie> <4385155269B445AEAF27DC8639A953D7@rainbow> <20100818154130.GC9431@localhost> <565A4EE71DAC4B1A820B2748F56ABF73@rainbow> <20100819074602.GW19797@csn.ul.ie> <5EF4FA9117384B1A80228C96926B4125@rainbow> <20100820055006.GA13916@localhost>
Subject: Re: compaction: trying to understand the code
Date: Fri, 20 Aug 2010 15:13:33 +0900
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_00E8_01CB407A.41303FE0"
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ying Han <yinghan@google.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

------=_NextPart_000_00E8_01CB407A.41303FE0
Content-Type: text/plain;
	format=flowed;
	charset="ISO-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit

> That's all? Is you system idle otherwise? (for example, fresh booted
> and not running many processes)

Sorry, I didn't mean that. There are other processes running.
I just meant my test doesn't do anything else.

> We are interested in the test app, can you share it? :)

Attached.

Thanks
Iram

------=_NextPart_000_00E8_01CB407A.41303FE0
Content-Type: application/octet-stream;
	name="mfragprog.c"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="mfragprog.c"

#include <stdlib.h>
#include <stdio.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <asm/types.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>
#include <errno.h>
#include <string.h>

#define TRYNUMMAX (1024*50)
static void *p[TRYNUMMAX] =3D {(void *)1, };
static size_t size;
static int trynum;

static void mfrag(void)
{
	int i;

	fprintf(stderr, "size, trynum: %d %d\n", size, trynum);

	for (i=3D0; i<trynum; i++) {
			p[i] =3D NULL;
	}

	for (i=3D0; i<trynum; i++) {
		p[i] =3D malloc(size);
		if (p[i]) {
			fprintf(stderr, "(%s:%s:%d) Success %d %d %p\n", __FILE__, =
__FUNCTION__, __LINE__, size, i, p[i]);
			memset(p[i], 'a', size);
		}
		else {
			fprintf(stderr, "(%s:%s:%d) Fail %d %d\n", __FILE__, __FUNCTION__, =
__LINE__, size, i);
			break;
		}
	}

	fprintf(stderr, "%d allocs done\n", i);

	for (i=3D0; i<trynum; i+=3D2) {
		if (p[i]) {
			free(p[i]);
			p[i] =3D NULL;
		}
	}

	fprintf(stderr, "frag done\n");
}

int main (int argc, char **argv)
{
	if (argc !=3D 3) {
		fprintf(stderr, "usage: %s <size> <trynum>\n", argv[0]);
		exit(1);
	}

	size =3D atoi(argv[1]);
	trynum =3D atoi(argv[2]);
	if (trynum > TRYNUMMAX) {
		trynum =3D TRYNUMMAX;
	}
=09
	mfrag();
=09
	while (1) {
		fprintf(stdout, "(%s:%s:%d)\n", __FILE__, __FUNCTION__, __LINE__);
		sleep(3);
	}
}

------=_NextPart_000_00E8_01CB407A.41303FE0--


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
