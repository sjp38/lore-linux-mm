Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m6UF8S2n006385
	for <linux-mm@kvack.org>; Wed, 30 Jul 2008 11:08:28 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6UF8Sou171750
	for <linux-mm@kvack.org>; Wed, 30 Jul 2008 11:08:28 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6UF8R6Z008339
	for <linux-mm@kvack.org>; Wed, 30 Jul 2008 11:08:28 -0400
Date: Wed, 30 Jul 2008 08:08:11 -0700
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: Re: [RFC] [PATCH 0/5 V2] Huge page backed user-space stacks
Message-ID: <20080730150811.GB20465@us.ibm.com>
References: <cover.1216928613.git.ebmunson@us.ibm.com> <20080730014139.39b3edc5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="rS8CxjVDS/+yyDmU"
Content-Disposition: inline
In-Reply-To: <20080730014139.39b3edc5.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

--rS8CxjVDS/+yyDmU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

/***************************************************************************
 *   User front end for using huge pages Copyright (C) 2008, IBM           *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the Lesser GNU General Public License as        *
 *   published by the Free Software Foundation; either version 2.1 of the  *
 *   License, or at your option) any later version.                        *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU Lesser General Public License for more details.                   *
 *                                                                         *
 *   You should have received a copy of the Lesser GNU General Public      *
 *   License along with this program; if not, write to the                 *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>

#define _GNU_SOURCE /* for getopt_long */
#include <unistd.h>
#include <getopt.h>
#include <sys/personality.h>

/* Peronsality bit for huge page backed stack */
#ifndef HUGETLB_STACK
#define HUGETLB_STACK 0x0020000
#endif

extern int errno;
extern int optind;
extern char *optarg;

void print_usage()
{
	fprintf(stderr, "hugectl [options] target\n");
	fprintf(stderr, "options:\n");
	fprintf(stderr, " --help,  -h  Prints this message.\n");
	fprintf(stderr,
		" --stack, -s  Attempts to execute target program with a hugtlb page backed stack.\n");
}

void set_huge_stack()
{
	char * err;
	unsigned long curr_per = personality(0xffffffff);
	if (personality(curr_per | HUGETLB_STACK) == -1) {
		err = strerror(errno);
		fprintf(stderr,
			"Error setting HUGE_STACK personality flag: '%s'\n",
			err);
		exit(-1);
	}
}

int main(int argc, char** argv)
{
	char opts [] = "+hs";
	int ret = 0, index = 0;
	struct option long_opts [] = {
		{"help",          0, 0, 'h'},
		{"stack",         0, 0, 's'},
		{0,               0, 0, 0},
	};

	if (argc < 2) {
		print_usage();
		return 0;
	}

	while (ret != -1) {
		ret = getopt_long(argc, argv, opts, long_opts, &index);
		switch (ret) {
		case 's':
			set_huge_stack();
			break;

		case '?':
		case 'h':
			print_usage();
			return 0;

		case -1:
			break;

		default:
			ret = -1;
			break;
		}
	}
	index = optind;

	if (execvp(argv[index], &argv[index]) == -1) {
		ret = errno;
		fprintf(stderr, "Error calling execvp: '%s'\n", strerror(ret));
		return ret;
	}

	return 0;
}


--rS8CxjVDS/+yyDmU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFIkIPbsnv9E83jkzoRApWQAJ49otiwlf5b1ooZnWdLv1XpcrFEjQCgj9Gc
q1ncDVumvxsGVpw3BUD6cT8=
=syC9
-----END PGP SIGNATURE-----

--rS8CxjVDS/+yyDmU--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
