Received: from cesarb by flower.cesarb.personal with local (Exim 3.16 #1 (Debian))
	id 13TvAS-0000Hr-00
	for <linux-mm@kvack.org>; Tue, 29 Aug 2000 20:51:48 -0300
Date: Tue, 29 Aug 2000 20:51:48 -0300
Subject: sieve.c
Message-ID: <20000829205148.A1052@cesarb.personal>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="k1lZvvs/B4yU6o8G"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
From: Cesar Eduardo Barros <cesarb@nitnet.com.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

Some time ago I sent riel and quintela a program which, used with the right
parameter, turns into a kinda "worst case" memory trasher. Since it looks like
they didn't have enough time to look into it, I'm sending it to the whole list
now.

I also figured out the ideal number to stress test everything is 16 times your
memory size in bytes (of course you can use more or maybe less, which makes the
effect in the memory subsystem a bit different).

----- Forwarded message from cesarb -----

Date: Sun, 20 Aug 2000 01:25:34 -0300
To: quintela@fi.udc.es
Cc: riel@conectiva.com.br
Subject: [cesarb: sieve.c]
User-Agent: Mutt/1.2.5i

riel thinks this should be included in your memtest suite. So I put it in
public domain (as something that simple deserves).

It was a sieve program I made last year. Was also my first pthreads program
(since I *had* to move the printf out of the main loop, it was killing the
performance).

riel says it is a pretty realistic sweep pattern.

The only change you might want to make to it (to make it work even better as a
VM test) would be to comment out the printf ("%u ", I2N (i)); from the output
loop, so the last sweep still gets done but is not dependent anymore in the tty
speed (you should also comment out the printf ("%u ", 2); line). Leave the
final count output there to check for bad runtime errors.

If you want to use it for even larger numbers (but getting a bit more CPU
bound) you should comment out the output lines I mentioned above, change bitpos
to a unsigned long long, and change BITPOS_FORMAT to match. I didn't test that,
but the program was ready for that kind of change from day one.

You could also include this email in your test suite's documentation. It's
pretty much the only documentation sieve.c would get.

----- Forwarded message from cesarb -----

Date: Sun, 20 Aug 2000 00:57:32 -0300
To: riel@conectiva.com.br
Subject: sieve.c
User-Agent: Mutt/1.2.5i

Here is it. I compile it with gcc -W -Wall -O3 -march=k6 -lpthread -save-temps

You need 1 billion (bah, screw the english. Um bilhao) maximum to get 60Mb
core. 2 billion get you 118Mb, which causes severe trashing and awful latency
on a 128Mb machine with X+gnome+mozilla+xmms+xchat+lotsa xterms+the kitchen
sink running.

----- End forwarded message -----

----- End forwarded message -----

-- 
Cesar Eduardo Barros
cesarb@nitnet.com.br
cesarb@dcc.ufrj.br

--k1lZvvs/B4yU6o8G
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="sieve.c"

/* sieve.c - Crivo de Eratostenes
 *
 * Estudante: Cesar Eduardo Barros (991.302.397)
 * Data: 22 de Maio de 1999
 *
 * Feito num AMD K6 rodando Linux */

#define _GNU_SOURCE
/* define funcoes seguras para threads */
#define _REENTRANT
#define _THREAD_SAFE

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <pthread.h>

/* Note: ao mudar algo no codigo, cuidado para nao confudir N's com I's e
 * esquecer a conversao */

typedef unsigned unit;
typedef unsigned bitpos;

#define UNIT_SIZE_BYTES (sizeof (unit))
#define UNIT_SIZE_BITS (UNIT_SIZE_BYTES * 8)
#define UNIT_FORMAT "%u"
#define BITPOS_FORMAT "%u"

/* forces rounding up */
#define NUM_UNITS(n) (((n) + (UNIT_SIZE_BITS - 1)) / UNIT_SIZE_BITS)
#define NUM_BYTES(n) (NUM_UNITS(n) * UNIT_SIZE_BYTES)

#define BIT_MASK(b) ((unit)0x1 << ((b) % UNIT_SIZE_BITS))
#define BIT_MASK_ALL (~ (unit)0x0)
#define BIT_MASK_NONE ((unit)0x0)
/* WARNING! These macros evaluate b twice on non-GNU compilers */
#ifndef __GNUC__
#define GET_BIT(v,b) ((v) [(b) / UNIT_SIZE_BITS] & BIT_MASK ((b)))
#define SET_BIT(v,b) ((v) [(b) / UNIT_SIZE_BITS] |= BIT_MASK ((b)))
#define CLEAR_BIT(v,b) ((v) [(b) / UNIT_SIZE_BITS] &= ~ BIT_MASK ((b)))
#else
#define GET_BIT(v,b) ( __extension__ ({ bitpos _b = (b); \
			(v) [_b / UNIT_SIZE_BITS] & BIT_MASK (_b); }))
#define SET_BIT(v,b) ( __extension__ ({ bitpos _b = (b); \
			(v) [_b / UNIT_SIZE_BITS] |= BIT_MASK (_b); ; }))
#define CLEAR_BIT(v,b) ( __extension__ ({ bitpos _b = (b); \
			(v) [_b / UNIT_SIZE_BITS] &= ~ BIT_MASK (_b); ; }))
#endif

/* nota: arrays em C comecam por 0, arrays de bits tambem */
#define I2N(i) (2 * (i) + 3)
#define N2I(n) (((n) - 3) / 2)

static bitpos printf_i, printf_N2I_limit;
static pthread_mutex_t printf_mutex;

static void * printf_thread (void * p)
{
	bitpos temp_printf_i;
	bitpos N2I_limit;
	struct timespec timer;

	timer.tv_sec = 0;
	timer.tv_nsec = 100000;

	N2I_limit = printf_N2I_limit;

	while (1)
	{
		pthread_mutex_lock (&printf_mutex);
		temp_printf_i = printf_i;
		pthread_mutex_unlock (&printf_mutex);
	
		fprintf (stderr, "\r%3f%%",
				temp_printf_i * 100. / N2I_limit);
		fflush (stderr);

		nanosleep (&timer, NULL);
	}
}

int main (int argc, char * argv[])
{
	unit * sieve;
	bitpos limit;
	bitpos i, j;
	bitpos count;
	/* threading (for printf) */
	pthread_t t;
	bitpos N2I_limit;

	fprintf (stderr, "Maximum: ");
	fflush (stderr);
	scanf (BITPOS_FORMAT, &limit);

	if (limit <= 2)
		goto out_small_limit;

	N2I_limit = N2I (limit);

	sieve = malloc (NUM_BYTES (N2I_limit + 1));
	if (sieve == NULL)
		goto out_no_mem;

	for (i = 0; i < NUM_UNITS (N2I_limit); ++i)
		sieve [i] = BIT_MASK_NONE;

	printf_i = 0;
	printf_N2I_limit = N2I_limit;
	pthread_mutex_init (&printf_mutex, NULL);
	pthread_create (&t, NULL, printf_thread, NULL);

	for (i = 0; i <= N2I_limit; ++i)
	{
		/* meus testes mostraram que printf() estava reduzindo muito a
		 * velocidade neste ponto quando i tendia a N2I (limit).
		 * Portanto dividi o programa em dois threads para reduzir a
		 * taxa de chamadas a printf sem complicar muito o codigo */
		/* note que o loop ainda para neste ponto durante chamadas a
		 * printf, se printf_thread travar o mutex enquanto tenta-se
		 * trava-lo aqui. Isso nao faz muita diferenca uma vez que o
		 * mutex e travado pelo menor tempo possivel */
		/* O calculo da percentagem tambem foi movido para
		 * printf_thread; agora esta thread nao usa ponto flutuante no
		 * loop (evitando as computacoes caras de ponto flutuante) */
		pthread_mutex_lock (&printf_mutex);
		printf_i = i;
		pthread_mutex_unlock (&printf_mutex);

		if (!GET_BIT (sieve, i))
			for (j = i + I2N (i); j <= N2I_limit; j += I2N (i))
				SET_BIT (sieve, j);
	}

	pthread_cancel (t);
	pthread_join (t, NULL);
	pthread_mutex_destroy (&printf_mutex);

	fprintf (stderr, "\n");

	printf ("%u ", 2);
	count = 1; /* 2 included here */
	for (i = 0; i <= N2I_limit; ++i)
		if (!GET_BIT (sieve, i))
		{
			printf ("%u ", I2N (i));
			++count;
		}

	printf ("\nPrimes found: " BITPOS_FORMAT "\n", count);

	free (sieve);

	return EXIT_SUCCESS;

out_small_limit:
	fprintf (stderr, "%s: Maximum too small\n", argv [0]);
	return EXIT_FAILURE;

out_no_mem:
	perror (argv[0]);
	return EXIT_FAILURE;
}

--k1lZvvs/B4yU6o8G--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
