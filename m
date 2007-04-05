Date: Wed, 4 Apr 2007 21:14:58 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: missing madvise functionality
Message-ID: <20070405041458.GP2986@holomorphy.com>
References: <46128051.9000609@redhat.com> <p73648dz5oa.fsf@bingen.suse.de> <46128CC2.9090809@redhat.com> <20070403172841.GB23689@one.firstfloor.org> <20070403125903.3e8577f4.akpm@linux-foundation.org> <4612B645.7030902@redhat.com> <20070403202937.GE355@devserv.devel.redhat.com> <20070404130918.GK2986@holomorphy.com> <20070404115105.ebaff52a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070404115105.ebaff52a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jakub Jelinek <jakub@redhat.com>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Apr 2007 06:09:18 -0700 William Lee Irwin III <wli@holomorphy.com> wrote:
>> Oh dear.

On Wed, Apr 04, 2007 at 11:51:05AM -0700, Andrew Morton wrote:
> what's all this about?

I rewrote Jakub's testcase and included it as a MIME attachment.
Current working version inline below. Also at

	http://holomorphy.com/~wli/jakub.c

The basic idea was that I wanted a few more niceties, such as specifying
the number of iterations and other things of that nature on the cmdline.
I threw in a little code reorganization and error checking, too.


-- wli


#include <pthread.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <stdint.h>
#include <sys/mman.h>
#include <sys/time.h>
#include <sys/resource.h>

enum thread_return {
	tr_success	=  0,
	tr_mmap_init	= -1,
	tr_mmap_free	= -2,
	tr_mprotect	= -3,
	tr_madvise	= -4,
	tr_unknown	= -5,
	tr_munmap	= -6,
};

enum release_method {
	release_by_mmap		= 0,
	release_by_madvise	= 1,
	release_by_max		= 2,
};

struct thread_argument {
	size_t page_size;
	int iterations, pages_per_thread, nr_threads;
	enum release_method method;
};

static enum thread_return mmap_release(void *p, size_t n)
{
	void *q;

	q = mmap(p, n, PROT_NONE, MAP_PRIVATE|MAP_ANONYMOUS|MAP_FIXED, -1, 0);
	if (p != q) {
		perror("thread_function: mmap release failed");
		return tr_mmap_free;
	}
	if (mprotect(p, n, PROT_READ | PROT_WRITE)) {
		perror("thread_function: mprotect failed");
		return tr_mprotect;
	}
	return tr_success;
}

static enum thread_return madvise_release(void *p, size_t n)
{
	if (madvise(p, n, MADV_DONTNEED)) {
		perror("thread_function: madvise failed");
		return tr_madvise;
	}
	return tr_success;
}

static enum thread_return (*release_methods[])(void *, size_t) = {
	mmap_release,
	madvise_release,
};

static void *thread_function(void *__arg)
{
	char *p;
	int i;
	struct thread_argument *arg = __arg;
	size_t arena_size = arg->pages_per_thread * arg->page_size;

	p = (char *)mmap(NULL, arena_size,
				PROT_READ | PROT_WRITE,
				MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
	if (p == MAP_FAILED) {
		perror("thread_function: arena allocation failed");
		return (void *)tr_mmap_init;
	}
	for (i = 0; i < arg->iterations; i++) {
		size_t s;
		char *q, *r;
		enum thread_return ret;

		/* Pretend to use the buffer.  */
		r = p + arena_size;
		for (q = p; q < r; q += arg->page_size)
			*q = 1;
		for (s = 0, q = p; q < r; q += arg->page_size)
			s += *q;
		if (arg->method >= release_by_max) {
			perror("thread_function: "
				"unknown freeing method specified");
			return (void *)tr_unknown;
		}
		ret = (*release_methods[arg->method])(p, arena_size);
		if (ret != tr_success)
			return (void *)ret;
	}
	if (munmap(p, arena_size)) {
		perror("thread_function: munmap() failed");
		return (void *)tr_munmap;
	}
	return (void *)tr_success;
}

static int configure(struct thread_argument *arg, int argc, char *argv[])
{
	char optstring[] = "t:m:i:p:";
	int c, tmp, ret = 0;
	long n;

	n = sysconf(_SC_PAGE_SIZE);
	if (n < 0) {
		perror("configure: sysconf(_SC_PAGE_SIZE) failed");
		ret = -1;
	}
	arg->nr_threads = 32, 
	arg->page_size = (size_t)n;
	arg->method = release_by_mmap;
	arg->iterations = 100000;
	arg->pages_per_thread = 128;

	while ((c = getopt(argc, argv, optstring)) != -1) {
		switch (c) {
			case 't':
				if (sscanf(optarg, "%d", &tmp) == 1)
					arg->nr_threads = tmp;
				else {
					perror("configure: non-numeric thread count");
					ret = -1;
				}
				break;
			case 'm':
				if (!strcmp(optarg, "mmap"))
					arg->method = release_by_mmap;
				else if (!strcmp(optarg, "madvise"))
					arg->method = release_by_madvise;
				else {
					perror("configure: unrecognised release method");
					ret = -1;
				}
				break;
			case 'i':
				if (sscanf(optarg, "%d", &tmp) == 1)
					arg->iterations = tmp;
				else {
					perror("configure: non-numeric iteration count");
					ret = -1;
				}
				break;
			case 'p':
				if (sscanf(optarg, "%d", &tmp) == 1)
					arg->pages_per_thread = tmp;
				else {
					perror("configure: non-numeric pages per thread count");
					ret = -1;
				}
				break;
			default:
				perror("unrecognignized argument");
				ret = -1;
		}
	}
	if (arg->nr_threads <= 0) {
		perror("configure: zero or negative thread count");
		ret = -1;
	}
	if (arg->iterations < 0) {
		perror("configure: negative iteration count");
		ret = -1;
	}
	if (arg->pages_per_thread <= 0) {
		perror("configure: zero or negative arena size");
		ret = -1;
	}
	if (SIZE_MAX/arg->page_size < (size_t)arg->pages_per_thread) {
		perror("configure: arena size overflow");
		ret = -1;
	}
	return ret;
}

static unsigned long long timeval_to_usec(struct timeval *tv)
{
	return 1000000*tv->tv_sec + tv->tv_usec;
}

static unsigned long long elapsed_usec(struct timeval *tv1, struct timeval *tv2)
{
	return timeval_to_usec(tv2) - timeval_to_usec(tv1);
}

#define user_usec(ru)	timeval_to_usec(&(ru)->ru_utime)
#define sys_usec(ru)	timeval_to_usec(&(ru)->ru_stime)
#define user_sec(ru)	((user_usec(ru) % 60000000ULL)/1000000.0)
#define sys_sec(ru)	((sys_usec(ru) % 60000000ULL)/1000000.0)
#define elapsed_sec(tv1, tv2)						\
		((elapsed_usec(tv1, tv2) % 60000000ULL)/1000000.0)

#define user_min(ru)	((unsigned long)((user_usec(ru)/60000000ULL) % 60))
#define sys_min(ru)	((unsigned long)((sys_usec(ru)/60000000ULL) % 60))
#define elapsed_min(tv1, tv2)						\
		((unsigned long)((elapsed_usec(tv1, tv2)/60000000ULL) % 60))

#define user_hrs(ru)	((unsigned long)(user_usec(ru)/3600000000ULL))
#define sys_hrs(ru)	((unsigned long)(user_usec(ru)/3600000000ULL))
#define elapsed_hrs(tv1, tv2)						\
		((unsigned long)(elapsed_usec(tv1, tv2)/3600000000ULL))

int main(int argc, char *argv[])
{
	int i, ret = EXIT_SUCCESS;
	struct thread_argument arg;
	struct rusage ru;
	struct timeval start, finish;
	pthread_t *th;

	if (gettimeofday(&start, NULL)) {
		perror("main: initial gettimeofday failed");
		return EXIT_FAILURE;
	}
	if (configure(&arg, argc, argv))
		return EXIT_FAILURE;
	th = calloc(arg.nr_threads, sizeof(pthread_t));
	if (!th) {
		perror("main: calloc of thread array failed");
		return EXIT_FAILURE;
	}
	for (i = 0; i < arg.nr_threads; i++) {
		if (pthread_create(&th[i], NULL, thread_function, &arg)) {
			perror("main: pthread_create failed");
			break;
		}
	}
	for (--i; i >= 0; --i) {
		void *status;

		if (pthread_join(th[i], &status)) {
			perror("main: pthread_join failed");
			ret = EXIT_FAILURE;
		} else if (status != (void *)tr_success)
			ret = EXIT_FAILURE;
	}
	free(th);
	getrusage(RUSAGE_SELF, &ru);
	if (gettimeofday(&finish, NULL)) {
		perror("final gettimeofday failed");
		ret = EXIT_FAILURE;
	}
	if (printf("%lu:%.2lu:%05.2lf elapsed time\n"
		"%lu:%.2lu:%05.2lf user time\n"
		"%lu:%.2lu:%05.2lf system time\n"
		"%ld major faults\n"
		"%ld minor faults\n"
		"%ld voluntary context switches\n"
		"%ld involuntary context switches\n",
		elapsed_hrs(&start, &finish),
			elapsed_min(&start, &finish),
			elapsed_sec(&start, &finish),
		user_hrs(&ru), user_min(&ru), user_sec(&ru),
		sys_hrs(&ru), sys_min(&ru), sys_sec(&ru),
		ru.ru_majflt,
		ru.ru_minflt,
		ru.ru_nvcsw,
		ru.ru_nivcsw) < 0)
			ret = EXIT_FAILURE;
	return ret;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
