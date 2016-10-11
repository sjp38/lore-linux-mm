Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1B65A6B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 08:53:55 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id n189so13592956qke.0
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 05:53:55 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id b139si1373073qka.131.2016.10.11.05.53.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 11 Oct 2016 05:53:47 -0700 (PDT)
Subject: Re: [RFC v2 PATCH] mm/percpu.c: simplify grouping CPU algorithm
References: <701fa92a-026b-f30b-833c-a5e61eab6549@zoho.com>
From: zijun_hu <zijun_hu@zoho.com>
Message-ID: <20a0123b-1205-a5ec-7af1-57da8f0f242c@zoho.com>
Date: Tue, 11 Oct 2016 20:53:35 +0800
MIME-Version: 1.0
In-Reply-To: <701fa92a-026b-f30b-833c-a5e61eab6549@zoho.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, akpm@linux-foundation.org
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux.com

On 2016/10/11 20:48, zijun_hu wrote:
> From: zijun_hu <zijun_hu@htc.com>

> in order to verify the new algorithm, we enumerate many pairs of type
> @pcpu_fc_cpu_distance_fn_t function and the relevant CPU IDs array such
> below sample, then apply both algorithms to the same pair and print the
> grouping results separately, the new algorithm is okay after checking
> whether the result printed from the new one is same with the original.
> a sample pair of function and array format is shown as follows:
> /* group CPUs by even/odd number */
> static int cpu_distance_fn0(int from, int to)
> {
> 	if (from % 2 ^ to % 2)
> 		return REMOTE_DISTANCE;
> 	else
> 		return LOCAL_DISTANCE;
> }
> /* end with -1 */
> int cpu_ids_0[] = {0, 1, 2, 3, 7, 8, 9, 11, 14, 17, 19, 20, 22, 24, -1};
> 
> Signed-off-by: zijun_hu <zijun_hu@htc.com>
> Tested-by: zijun_hu <zijun_hu@htc.com>
> ---
how to test the new grouping CPU algorithm ?
1) copy the test source code to a file named percpu_group_test.c
2) compile the test program with below command line
   gcc -Wall -o percpu_group_test percpu_group_test.c
3) get usage info about the percpu_group_test
   ./percpu_group_test -h
4) produce the grouping result by the new algorithm
   ./percpu_group_test new > percpu.new
5) produce the grouping result by the original algorithm
   ./percpu_group_test orig > percpu.orig
6) examine the test result; okay if same result; otherwise, failed
   diff -u percpu.new percpu.orig

test program sources is shown as follows:

#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#define LOCAL_DISTANCE		10
#define REMOTE_DISTANCE		20

#define NR_CPUS 96
static int nr_groups;
static int group_map[NR_CPUS];
static int group_cnt[NR_CPUS];

static int *cpu_ids_ptr;
static int (*cpu_distance_fn) (int from, int to);

static int cpu_distance_fn0(int from, int to);
extern int cpu_ids_0[];

static int cpu_distance_fn1(int from, int to);
extern int cpu_ids_1[];

static int cpu_distance_fn2(int from, int to);
extern int cpu_ids_2[];

int (*cpu_distance_funcx[]) (int, int) = {
cpu_distance_fn0, cpu_distance_fn1, cpu_distance_fn2, NULL};
int *cpu_ids_x[] = { cpu_ids_0, cpu_ids_1, cpu_ids_2, NULL };

static void percpu_test_prepare(int test_type)
{
	nr_groups = 0;
	memset(group_map, 0xff, sizeof(group_map));
	memset(group_cnt, 0xff, sizeof(group_cnt));

	cpu_ids_ptr = cpu_ids_x[test_type];
	cpu_distance_fn = cpu_distance_funcx[test_type];
}

static int next_cpu(int cpu)
{
	int i = 0;
	while (cpu_ids_ptr[i] != cpu)
		i++;
	return cpu_ids_ptr[i + 1];
}

#define for_each_possible_cpu(cpu)				\
	for ((cpu) = cpu_ids_ptr[0];				\
		(cpu) != -1;	\
		(cpu) = next_cpu((cpu)))

#define max(v0, v1) ((v0) > (v1) ? (v0) : (v1))

static void percpu_result_printf(void)
{
	int g;
	int c;

	printf("nr_groups = %d\n", nr_groups);
#if 0
	for_each_possible_cpu(c)
	    if (group_map[c] != -1)
		printf("group_map[%d] = %d\n", c, group_map[c]);
	for (g = 0; g < nr_groups; g++)
		printf("group_cnt[%d] = %d\n", g, group_cnt[g]);
#else
	for (g = 0; g < nr_groups; g++) {
		printf("group id %d : ", g);
		for_each_possible_cpu(c)
		    if (group_map[c] == g)
			printf("%d ", c);
		printf("\n");
	}
	printf("\n");
#endif
}

/*
 * group cpus by even or odd ids
 */
static int cpu_distance_fn0(int from, int to)
{
	if (from % 2 ^ to % 2)
		return REMOTE_DISTANCE;
	else
		return LOCAL_DISTANCE;
}

/* end with -1 */
int cpu_ids_0[] = { 0, 1, 2, 3, 7, 8, 9, 11, 14, 17, 19, 20, 22, 24, 31, -1 };

/*
 * group cpus by 3x of cpu ids
 */
int cpu_distance_fn1(int from, int to)
{
	if (from % 3 == 0 && to % 3 == 0)
		return LOCAL_DISTANCE;
	else if (from % 3 && to % 3)
		return LOCAL_DISTANCE;
	else
		return REMOTE_DISTANCE;
}
int cpu_ids_1[] = { 0, 3, 5, 6, 8, 9, 10, 11, 12, 14, 17, 18, 21, 24, 25, -1 };

/*
 * group cpus by range, [..., 10), [10, 20), [20, ...)
 */
int cpu_distance_fn2(int from, int to)
{
	if (from < 10 && to < 10)
		return LOCAL_DISTANCE;
	else if (from >= 20 && to >= 20)
		return LOCAL_DISTANCE;
	else if ((from >= 10 && from < 20) && (to >= 10 && to < 20))
		return LOCAL_DISTANCE;
	else
		return REMOTE_DISTANCE;

}
int cpu_ids_2[] =
    { 0, 1, 2, 4, 6, 8, 9, 10, 12, 15, 16, 18, 19, 20, 22, 25, 27, -1 };

void orig_group_cpus(int test_type)
{
	int group;
	int cpu, tcpu;
	percpu_test_prepare(test_type);

	/* group cpus according to their proximity */
	for_each_possible_cpu(cpu) {
		group = 0;
next_group:
		for_each_possible_cpu(tcpu) {
			if (cpu == tcpu)
				break;
			if (group_map[tcpu] == group && cpu_distance_fn &&
			    (cpu_distance_fn(cpu, tcpu) > LOCAL_DISTANCE ||
			     cpu_distance_fn(tcpu, cpu) > LOCAL_DISTANCE)) {
				group++;
				nr_groups = max(nr_groups, group + 1);
				goto next_group;
			}
		}
		group_map[cpu] = group;
		group_cnt[group]++;
	}

	percpu_result_printf();
}

void fix_group_cpus(int test_type)
{
	int group;
	int cpu, tcpu;
	percpu_test_prepare(test_type);

	/* group cpus according to their proximity */
	group = 0;
	for_each_possible_cpu(cpu)
	    for_each_possible_cpu(tcpu) {
		if (tcpu == cpu) {
			group_map[cpu] = group;
			group_cnt[group] = 1;
			group++;
			break;
		}

		if (!cpu_distance_fn ||
		    (cpu_distance_fn(cpu, tcpu) == LOCAL_DISTANCE &&
		     cpu_distance_fn(tcpu, cpu) == LOCAL_DISTANCE)) {
			group_map[cpu] = group_map[tcpu];
			group_cnt[group_map[cpu]]++;
			break;
		}
	}
	nr_groups = group;

	percpu_result_printf();
}

int main(int argc, char *argv[])
{
	int ret = -1;
	int is_new;
	int test_type;

	if (argc < 2)
		goto help_out;

	if (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0) {
		ret = 0;
		goto help_out;
	}

	if (strcmp(argv[1], "new") == 0)
		is_new = 1;
	else if (strcmp(argv[1], "orig") == 0)
		is_new = 0;
	else
		goto help_out;

	printf("is_new = %d\n", is_new);
	for (test_type = 0; cpu_ids_x[test_type] != NULL; test_type++)
		if (is_new)
			fix_group_cpus(test_type);
		else
			orig_group_cpus(test_type);
	ret = 0;
	return ret;

help_out:
	printf("Usage : %s -h|--help|new|orig\n", argv[0]);
	printf("\t-h|--help : ouput this help message\n");
	printf("\tnew : get the results of grouping cpu by new \
algorithm\n");
	printf("\torig : get the results of grouping cpu by \
original algorithm\n");
	printf("new algorithm can be verified by run this test \
program with parameter\n");
	printf("new and orig respectively, then check whether the \
output message are same\n");
	return ret;
}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
