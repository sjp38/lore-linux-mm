Received: from smtp3.akamai.com (vwall1.sanmateo.corp.akamai.com [172.23.1.71])
	by smtp3.akamai.com (8.12.10/8.12.10) with ESMTP id j0T1tlNZ003218
	for <linux-mm@kvack.org>; Fri, 28 Jan 2005 17:55:48 -0800 (PST)
Message-ID: <41FAEE42.8BFBA188@akamai.com>
Date: Fri, 28 Jan 2005 18:00:34 -0800
From: Prasanna Meda <pmeda@akamai.com>
MIME-Version: 1.0
Subject: Re: [patch] ext2: Apply Jack's ext3 speedups
References: <200501270722.XAA10830@allur.sanmateo.akamai.com> <20050127205233.GB9225@thunk.org> <41FAED57.DFCF1D22@akamai.com>
Content-Type: multipart/mixed;
 boundary="------------54EE5A15D1766C718AE5DFBA"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, akpm@osdl.org, jack@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------54EE5A15D1766C718AE5DFBA
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Prasanna Meda wrote:

>   - Folded all three root checkings for 3,  5 and 7 into one loop.
>   -  Short cut the loop with 3**n < 5 **n < 7**n logic.
>   -  Even numbers can be ruled out.
>
>   Tested with  user space programs.

  Test program and results attached.



Thanks,
Prasanna.

--------------54EE5A15D1766C718AE5DFBA
Content-Type: text/plain; charset=us-ascii;
 name="testroot.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="testroot.c"

/* 
 * TEST program to test root(a).
 * cc a.c -O3 -Wall -S
 *
 * Fold the root checking for 3, 5, 7 into a single loop
 * and exploit the concepts 3**n < 5**n < 7**n, and odd**n is odd.
 * And also odd power can not be even.
 * So number of multiplications will become less.
 */

#include <stdio.h>
#include <sys/time.h>
#include <stdlib.h>

static inline int test_root(int a, int b)
{
	int num = b;

	while(a > num)
		num *= b;

	return (num == a);
}

/* loop algorithm folded, shortcut 3*logn multiplications.  */
static inline int test_root2(int a)
{
	int num3 = 3, num5 = 5, num7 = 7;

	if  (num5 == a || num7 == a)
		return 1;

	if  (!(a & 1))
		return 0;

	while (a > num3) {
		num3 *= 3;

		if (a < num5)
			continue;
		num5 *= 5;
		if (num5 == a)
			return 1;

		if (a < num7)
			continue;
		num7 *= 7;
		if (num7 == a)
			return 1;
	}
	return (num3 == a);
}

/* 6*loglogn multiplications */
int test_root3(int a, int b)
{
	int factor, power = 1, guess = b;

	while (a >= guess)  {
		for (factor = b; a >= guess; factor *= factor) {
			power = guess;
			guess = guess * factor;
		}
		guess = power * b;
	}

	return (power == a);
}

int main(int argc, char *argv[])
{
	int a, b, d, ret = 0;

	if (argc < 3) {
		printf("Usage: %s num1 method\n", argv[0]);
		return 1;
	}
	a = atoi(argv[2]);  b = atoi(argv[1]);
	if (a != 1 && a != 2) {
		printf("%s: Method is one of the 1, 2 or 3.\n", argv[0]);
		return 1;
	}

	for (d = 1; d <10000000; d++) {
		switch(a) {
		case 1:
			ret = test_root(b, 3)
				|| test_root(b, 5)
				|| test_root(b, 7);
			break;
		case 2:
			ret = test_root2(b);
			break;
		}
	}

	switch(a) {
	case 1:
		printf("\nunfolded Alg:");
		break;
	case 2:
		printf("\nfolded   Alg:");
		break;
	}
	printf("%u is %s sparse\n", b, ret?"":"not");
	return 0;
}


--------------54EE5A15D1766C718AE5DFBA
Content-Type: text/plain; charset=us-ascii;
 name="testrootresults.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="testrootresults.txt"


# time ./a.out 2401 1; sleep 1; time ./a.out 2401 2

unfolded Alg:2401 is  sparse

real	0m2.485s
user	0m2.334s
sys	0m0.007s

folded   Alg:2401 is  sparse

real	0m1.047s
user	0m0.822s
sys	0m0.003s

# time ./a.out 2400 1; sleep 1; time ./a.out 2400 2 # even before even check.

unfolded Alg:2400 is not sparse

real	0m2.186s
user	0m2.083s
sys	0m0.003s

folded   Alg:2400 is not sparse

real	0m1.640s
user	0m1.418s
sys	0m0.003s

# time ./a.out 2400 2 # after adding even check.

folded   Alg:2400 is not sparse

real	0m0.277s
user	0m0.275s
sys	0m0.002s

# time ./a.out 625 1; sleep 1; time ./a.out 625 2

unfolded Alg:625 is  sparse

real	0m0.901s
user	0m0.715s
sys	0m0.004s

folded   Alg:625 is  sparse

real	0m0.542s
user	0m0.524s
sys	0m0.004s
 
# time ./a.out 243 1; sleep 1; time ./a.out 243 2

unfolded Alg:243 is  sparse

real	0m0.453s
user	0m0.442s
sys	0m0.003s

folded   Alg:243 is  sparse

real	0m0.854s
user	0m0.823s
sys	0m0.004s

# time ./a.out 729 1; sleep 1; time ./a.out 729 2

unfolded Alg:729 is  sparse

real	0m1.077s
user	0m1.062s
sys	0m0.001s

folded   Alg:729 is  sparse

real	0m1.083s
user	0m1.010s
sys	0m0.003s

# time ./a.out 6561 1; sleep 1; time ./a.out 6561 2

unfolded Alg:6561 is  sparse

real	0m1.299s
user	0m1.281s
sys	0m0.001s

folded   Alg:6561 is  sparse

real	0m1.436s
user	0m1.410s
sys	0m0.004s

# time ./a.out 15625 1; sleep 1; time ./a.out 15625 2

unfolded Alg:15625 is  sparse

real	0m2.259s
user	0m2.209s
sys	0m0.002s

folded   Alg:15625 is not sparse

real	0m1.896s
user	0m1.801s
sys	0m0.006s

# time ./a.out 15626 1; sleep 1; time ./a.out 15626 2

unfolded Alg:15626 is not sparse

real	0m2.609s
user	0m2.493s
sys	0m0.002s

folded   Alg:15626 is not sparse

real	0m2.209s
user	0m1.804s
sys	0m0.004s

# time ./a.out 15626 2 # after adding even number check

folded   Alg:15626 is not sparse

real	0m0.283s
user	0m0.276s
sys	0m0.001s




--------------54EE5A15D1766C718AE5DFBA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
