Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5A25D6B025B
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 05:56:44 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so172340776pad.3
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 02:56:44 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id ks2si21260585pbc.124.2015.09.15.02.56.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Tue, 15 Sep 2015 02:56:43 -0700 (PDT)
From: Junichi Nomura <j-nomura@ce.jp.nec.com>
Subject: Test program: check if fsync() can detect I/O error (1/2)
Date: Tue, 15 Sep 2015 09:49:47 +0000
Message-ID: <20150915094946.GB13399@xzibit.linux.bs1.fc.nec.co.jp>
References: <20150915094638.GA13399@xzibit.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20150915094638.GA13399@xzibit.linux.bs1.fc.nec.co.jp>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <3A819148444E9A4A9D6476EFFEEAAAED@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "andi@firstfloor.org" <andi@firstfloor.org>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>, "tony.luck@intel.com" <tony.luck@intel.com>, "liwanp@linux.vnet.ibm.com" <liwanp@linux.vnet.ibm.com>, "david@fromorbit.com" <david@fromorbit.com>, Tejun Heo <tj@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> However if admins run a command such as sync or fsfreeze along side,
> fsync/fdatasync may return success even if writeback has failed.
> That could lead to data corruption.

For reproducing the problem, compile the attached C program (iogen.c)
and run with 'runtest.sh' script in the next mail:
  # gcc -o iogen iogen.c
  # bash ./runtest.sh

"iogen" does write(), fsync() and checks if on-disk data is same
as application's buffer after successful fsync.
"runtest.sh" injects failure for the file being written by "iogen".
(You need to enable CONFIG_HWPOISON_INJECT=3Dm for the memory error
 injection to work.)

Without the patch, fsync returns success even though data is not on
disk.

  TEST: ext4 / ioerr / sync-command
  (iogen): inject
  (admin): Injecting I/O error
  (admin): Calling sync(2)
  (iogen): remove
  FAIL: corruption!
  DIFF 00000200: de de de de de de de de  | 00 00 00 00 00 00 00 00
  ...

With the patch, fsync detects error correctly.

  TEST: ext4 / ioerr / sync-command
  (iogen): inject
  (admin): Injecting I/O error
  (admin): Calling sync(2)
  INFO: App fsync: Input/output error
  (iogen): remove
  PASS: detected error right
  (iogen): end

-- cut here --
#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

unsigned char *app_buf;
unsigned char *ondisk_data;
char *testfile;
size_t buflen;
int fd;
int rfd;

void dumpdiff(unsigned char *buf1, unsigned char *buf2, int len)
{
	int i, j;
	for(i =3D 0; i < len; i +=3D 8) {
		if (!memcmp(&buf1[i], &buf2[i], 8))
			continue;
		fprintf(stderr, "DIFF %08x: ", i);
		for(j =3D 0; j < 8 && i + j < len; j++)
			fprintf(stderr, "%02x ", buf1[i]);
                fprintf(stderr, " | ");
		for(j =3D 0; j < 8 && i + j < len; j++)
			fprintf(stderr, "%02x ", buf2[i]);
                fprintf(stderr, "\n");
        }
}

void notify_injector(char *str)
{
        if (str)
                fprintf(stderr, "(iogen): %s\n", str);
        write(1, "\n", 2);
        sleep(1);
}

void open_fds(void)
{
	fd =3D open(testfile, O_RDWR);
	if (fd < 0) {
		perror("????: App open");
		exit(1);
	}
	rfd =3D open(testfile, O_RDONLY|O_DIRECT); /* for verification */
	if (rfd < 0) {
		perror("????: App open rfd");
		exit(1);
	}
}

void init_fd_status(void)
{
	int r;

	r =3D fsync(fd); /* flush and clean */
	if (r) {
		perror("????: App fsync0");
		exit(1);
	}
	r =3D pread(fd, app_buf, buflen, 0); /* stage onto cache */
	if (r !=3D buflen) {
		perror("????: App read1");
		exit(1);
	}
}

void close_fds(void)
{
	int r;

	r =3D close(rfd);
	if (r)
		perror("????: App close read fd");
	r =3D close(fd);
	if (r)
		perror("????: App close write fd");
}

void write_data(int cnt)
{
	int r;

	memset(app_buf, cnt, buflen);
	r =3D pwrite(fd, app_buf, buflen, 0);
	if (r !=3D buflen)
		perror("????: App write1");
}

int sync_data(void)
{
	int r, r2;

	r =3D fsync(fd);
	if (r)
		perror("INFO: App fsync");
	r2 =3D fsync(fd);
	if (r2)
		perror("????: App fsync (redo)");

	return r;
}

void read_data_direct(void)
{
	int r;

	r =3D pread(rfd, ondisk_data, buflen, 0);
	if (r !=3D buflen) {
		perror("????: App direct read");
		r =3D pread(rfd, ondisk_data, buflen, 0);
		if (r !=3D buflen)
			perror("FAIL: App direct read (retry)");
	}
}

void check_data(int fsync_result)
{
	int r;

	r =3D memcmp(app_buf, ondisk_data, buflen);
	if (r) {
		/* data is different */
		if (fsync_result =3D=3D 0) {
			fprintf(stderr, "FAIL: corruption!\n");
			dumpdiff(app_buf, ondisk_data, buflen);
		} else
			fprintf(stderr, "PASS: detected error right\n");
	} else {
		/* data is same */
		if (fsync_result =3D=3D 0)
			fprintf(stderr, "PASS: no error, data is ok\n");
		else
			fprintf(stderr, "????: sync failed, data is ok\n");
	}
}

void cleanup_data(int cnt)
{
	int r;

	/* write-fsync-read without error injection */
	memset(app_buf, cnt, buflen);
	r =3D pwrite(fd, app_buf, buflen, 0);
	if (r !=3D buflen)
		perror("BUG : App write (w/o failure)");
	r =3D fsync(fd);
	if (r)
		perror("BUG : App fsync (w/o failure)");
	r =3D pread(rfd, ondisk_data, buflen, 0);
	if (r !=3D buflen)
		perror("BUG : App read (w/o failure)");
	r =3D memcmp(app_buf, ondisk_data, buflen);
	if (r)
		fprintf(stderr, "BUG : memcmp failed\n");
}

/*
 * Do this:
 *   1) write
 *   2) inject failure
 *   3) fsync (should return error)
 *   4) remove failure
 *   5) check on-disk data (using direct read)
 */
void runtest(void)
{
	int fsync_result;

	notify_injector("start");
	open_fds();
	init_fd_status();

	write_data(0xde);
	notify_injector("inject");
	fsync_result =3D sync_data();
	notify_injector("remove");

	/* re-read and compare */
	read_data_direct();
	check_data(fsync_result);

	cleanup_data(0);
	close_fds();
	notify_injector("end");
}

int main(int argc, char **argv)
{
	testfile =3D argv[1];
	buflen =3D atoi(argv[2]);

	app_buf =3D malloc(buflen);
	if (!app_buf)
		exit(1);
	if (posix_memalign((void **) &ondisk_data, 4096, buflen))
		exit(1);

	runtest();

	free(app_buf);
	free(ondisk_data);

	return 0;
}=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
