Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id AE4666B0038
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 09:40:31 -0400 (EDT)
Received: by igbyr2 with SMTP id yr2so9622958igb.0
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 06:40:31 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id e1si1123992igi.5.2015.04.13.06.40.30
        for <linux-mm@kvack.org>;
        Mon, 13 Apr 2015 06:40:30 -0700 (PDT)
Date: Mon, 13 Apr 2015 10:40:24 -0300
From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH 4/9] perf kmem: Implement stat --page --caller
Message-ID: <20150413134024.GD3200@kernel.org>
References: <1428298576-9785-1-git-send-email-namhyung@kernel.org>
 <1428298576-9785-5-git-send-email-namhyung@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1428298576-9785-5-git-send-email-namhyung@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org

Em Mon, Apr 06, 2015 at 02:36:11PM +0900, Namhyung Kim escreveu:
> It perf kmem support caller statistics for page.  Unlike slab case,
> the tracepoints in page allocator don't provide callsite info.  So
> it records with callchain and extracts callsite info.
> 
> Note that the callchain contains several memory allocation functions
> which has no meaning for users.  So skip those functions to get proper
> callsites.  I used following regex pattern to skip the allocator
> functions:
> 
>   ^_?_?(alloc|get_free|get_zeroed)_pages?
> 
> This gave me a following list of functions:
> 
>   # perf kmem record --page sleep 3
>   # perf kmem stat --page -v
>   ...
>   alloc func: __get_free_pages
>   alloc func: get_zeroed_page
>   alloc func: alloc_pages_exact
>   alloc func: __alloc_pages_direct_compact
>   alloc func: __alloc_pages_nodemask
>   alloc func: alloc_page_interleave
>   alloc func: alloc_pages_current
>   alloc func: alloc_pages_vma
>   alloc func: alloc_page_buffers
>   alloc func: alloc_pages_exact_nid
>   ...
> 
> The output looks mostly same as --alloc (I also added callsite column
> to that) but groups entries by callsite.  Currently, the order,
> migrate type and GFP flag info is for the last allocation and not
> guaranteed to be same for all allocations from the callsite.
> 
>   ---------------------------------------------------------------------------------------------
>    Total_alloc (KB) | Hits      | Order | Mig.type | GFP flags | Callsite
>   ---------------------------------------------------------------------------------------------
>               1,064 |       266 |     0 | UNMOVABL |  000000d0 | __pollwait
>                  52 |        13 |     0 | UNMOVABL |  002084d0 | pte_alloc_one
>                  44 |        11 |     0 |  MOVABLE |  000280da | handle_mm_fault
>                  20 |         5 |     0 |  MOVABLE |  000200da | do_cow_fault
>                  20 |         5 |     0 |  MOVABLE |  000200da | do_wp_page
>                  16 |         4 |     0 | UNMOVABL |  000084d0 | __pmd_alloc
>                  16 |         4 |     0 | UNMOVABL |  00000200 | __tlb_remove_page
>                  12 |         3 |     0 | UNMOVABL |  000084d0 | __pud_alloc
>                   8 |         2 |     0 | UNMOVABL |  00000010 | bio_copy_user_iov
>                   4 |         1 |     0 | UNMOVABL |  000200d2 | pipe_write
>                   4 |         1 |     0 |  MOVABLE |  000280da | do_wp_page
>                   4 |         1 |     0 | UNMOVABL |  002084d0 | pgd_alloc
>   ---------------------------------------------------------------------------------------------
> 
> Signed-off-by: Namhyung Kim <namhyung@kernel.org>
> ---
>  tools/perf/builtin-kmem.c | 279 +++++++++++++++++++++++++++++++++++++++++++---
>  1 file changed, 263 insertions(+), 16 deletions(-)
> 
> diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
> index 63ea01349b6e..5b3ed17c293a 100644
> --- a/tools/perf/builtin-kmem.c
> +++ b/tools/perf/builtin-kmem.c
> @@ -10,6 +10,7 @@
>  #include "util/header.h"
>  #include "util/session.h"
>  #include "util/tool.h"
> +#include "util/callchain.h"
>  
>  #include "util/parse-options.h"
>  #include "util/trace-event.h"
> @@ -21,6 +22,7 @@
>  #include <linux/rbtree.h>
>  #include <linux/string.h>
>  #include <locale.h>
> +#include <regex.h>
>  
>  static int	kmem_slab;
>  static int	kmem_page;
> @@ -241,6 +243,7 @@ static unsigned long nr_page_fails;
>  static unsigned long nr_page_nomatch;
>  
>  static bool use_pfn;
> +static struct perf_session *kmem_session;
>  
>  #define MAX_MIGRATE_TYPES  6
>  #define MAX_PAGE_ORDER     11
> @@ -250,6 +253,7 @@ static int order_stats[MAX_PAGE_ORDER][MAX_MIGRATE_TYPES];
>  struct page_stat {
>  	struct rb_node 	node;
>  	u64 		page;
> +	u64 		callsite;
>  	int 		order;
>  	unsigned 	gfp_flags;
>  	unsigned 	migrate_type;
> @@ -262,8 +266,138 @@ struct page_stat {
>  static struct rb_root page_tree;
>  static struct rb_root page_alloc_tree;
>  static struct rb_root page_alloc_sorted;
> +static struct rb_root page_caller_tree;
> +static struct rb_root page_caller_sorted;
>  
> -static struct page_stat *search_page(unsigned long page, bool create)
> +struct alloc_func {
> +	u64 start;
> +	u64 end;
> +	char *name;
> +};
> +
> +static int nr_alloc_funcs;
> +static struct alloc_func *alloc_func_list;
> +
> +static int funcmp(const void *a, const void *b)
> +{
> +	const struct alloc_func *fa = a;
> +	const struct alloc_func *fb = b;
> +
> +	if (fa->start > fb->start)
> +		return 1;
> +	else
> +		return -1;
> +}
> +
> +static int callcmp(const void *a, const void *b)
> +{
> +	const struct alloc_func *fa = a;
> +	const struct alloc_func *fb = b;
> +
> +	if (fb->start <= fa->start && fa->end < fb->end)
> +		return 0;
> +
> +	if (fa->start > fb->start)
> +		return 1;
> +	else
> +		return -1;
> +}
> +
> +static int build_alloc_func_list(void)
> +{
> +	int ret;
> +	struct map *kernel_map;
> +	struct symbol *sym;
> +	struct rb_node *node;
> +	struct alloc_func *func;
> +	struct machine *machine = &kmem_session->machines.host;
> +

Why having a blank like here?

> +	regex_t alloc_func_regex;
> +	const char pattern[] = "^_?_?(alloc|get_free|get_zeroed)_pages?";
> +
> +	ret = regcomp(&alloc_func_regex, pattern, REG_EXTENDED);
> +	if (ret) {
> +		char err[BUFSIZ];
> +
> +		regerror(ret, &alloc_func_regex, err, sizeof(err));
> +		pr_err("Invalid regex: %s\n%s", pattern, err);
> +		return -EINVAL;
> +	}
> +
> +	kernel_map = machine->vmlinux_maps[MAP__FUNCTION];
> +	map__load(kernel_map, NULL);

What if the map can't be loaded?

> +
> +	map__for_each_symbol(kernel_map, sym, node) {
> +		if (regexec(&alloc_func_regex, sym->name, 0, NULL, 0))
> +			continue;
> +
> +		func = realloc(alloc_func_list,
> +			       (nr_alloc_funcs + 1) * sizeof(*func));
> +		if (func == NULL)
> +			return -ENOMEM;
> +
> +		pr_debug("alloc func: %s\n", sym->name);
> +		func[nr_alloc_funcs].start = sym->start;
> +		func[nr_alloc_funcs].end   = sym->end;
> +		func[nr_alloc_funcs].name  = sym->name;
> +
> +		alloc_func_list = func;
> +		nr_alloc_funcs++;
> +	}
> +
> +	qsort(alloc_func_list, nr_alloc_funcs, sizeof(*func), funcmp);
> +
> +	regfree(&alloc_func_regex);
> +	return 0;
> +}
> +
> +/*
> + * Find first non-memory allocation function from callchain.
> + * The allocation functions are in the 'alloc_func_list'.
> + */
> +static u64 find_callsite(struct perf_evsel *evsel, struct perf_sample *sample)
> +{
> +	struct addr_location al;
> +	struct machine *machine = &kmem_session->machines.host;
> +	struct callchain_cursor_node *node;
> +
> +	if (alloc_func_list == NULL)
> +		build_alloc_func_list();
> +
> +	al.thread = machine__findnew_thread(machine, sample->pid, sample->tid);
> +	sample__resolve_callchain(sample, NULL, evsel, &al, 16);
> +
> +	callchain_cursor_commit(&callchain_cursor);
> +	while (true) {
> +		struct alloc_func key, *caller;
> +		u64 addr;
> +
> +		node = callchain_cursor_current(&callchain_cursor);
> +		if (node == NULL)
> +			break;
> +
> +		key.start = key.end = node->ip;
> +		caller = bsearch(&key, alloc_func_list, nr_alloc_funcs,
> +				 sizeof(key), callcmp);
> +		if (!caller) {
> +			/* found */
> +			if (node->map)
> +				addr = map__unmap_ip(node->map, node->ip);
> +			else
> +				addr = node->ip;
> +
> +			return addr;
> +		} else
> +			pr_debug3("skipping alloc function: %s\n", caller->name);
> +
> +		callchain_cursor_advance(&callchain_cursor);
> +	}
> +
> +	pr_debug2("unknown callsite: %"PRIx64 "\n", sample->ip);
> +	return sample->ip;
> +}
> +
> +static struct page_stat *search_page(u64 page, bool create)
>  {
>  	struct rb_node **node = &page_tree.rb_node;
>  	struct rb_node *parent = NULL;
> @@ -357,6 +491,41 @@ static struct page_stat *search_page_alloc_stat(struct page_stat *stat, bool cre
>  	return data;
>  }
>  
> +static struct page_stat *search_page_caller_stat(u64 callsite, bool create)
> +{
> +	struct rb_node **node = &page_caller_tree.rb_node;
> +	struct rb_node *parent = NULL;
> +	struct page_stat *data;

Please use the "findnew" idiom to name this function, looking at only
its name one things it searches a tree, a read only operation, but it
may insert elements too, a modify operation.

Since we use the findnew idiom elsewhere for operations that do that,
i.e. optimize the "new" part of "findnew" by using the "find" part,
please use it here as well.

> +	while (*node) {
> +		s64 cmp;
> +
> +		parent = *node;
> +		data = rb_entry(*node, struct page_stat, node);
> +
> +		cmp = data->callsite - callsite;
> +		if (cmp < 0)
> +			node = &parent->rb_left;
> +		else if (cmp > 0)
> +			node = &parent->rb_right;
> +		else
> +			return data;
> +	}
> +
> +	if (!create)
> +		return NULL;
> +
> +	data = zalloc(sizeof(*data));
> +	if (data != NULL) {
> +		data->callsite = callsite;
> +
> +		rb_link_node(&data->node, parent, node);
> +		rb_insert_color(&data->node, &page_caller_tree);
> +	}
> +
> +	return data;
> +}
> +
>  static bool valid_page(u64 pfn_or_page)
>  {
>  	if (use_pfn && pfn_or_page == -1UL)
> @@ -375,6 +544,7 @@ static int perf_evsel__process_page_alloc_event(struct perf_evsel *evsel,
>  	unsigned int migrate_type = perf_evsel__intval(evsel, sample,
>  						       "migratetype");
>  	u64 bytes = kmem_page_size << order;
> +	u64 callsite;
>  	struct page_stat *stat;
>  	struct page_stat this = {
>  		.order = order,
> @@ -397,6 +567,8 @@ static int perf_evsel__process_page_alloc_event(struct perf_evsel *evsel,
>  		return 0;
>  	}
>  
> +	callsite = find_callsite(evsel, sample);
> +
>  	/*
>  	 * This is to find the current page (with correct gfp flags and
>  	 * migrate type) at free event.
> @@ -408,6 +580,7 @@ static int perf_evsel__process_page_alloc_event(struct perf_evsel *evsel,
>  	stat->order = order;
>  	stat->gfp_flags = gfp_flags;
>  	stat->migrate_type = migrate_type;
> +	stat->callsite = callsite;
>  
>  	this.page = page;
>  	stat = search_page_alloc_stat(&this, true);
> @@ -416,6 +589,18 @@ static int perf_evsel__process_page_alloc_event(struct perf_evsel *evsel,
>  
>  	stat->nr_alloc++;
>  	stat->alloc_bytes += bytes;
> +	stat->callsite = callsite;
> +
> +	stat = search_page_caller_stat(callsite, true);
> +	if (stat == NULL)
> +		return -ENOMEM;
> +
> +	stat->order = order;
> +	stat->gfp_flags = gfp_flags;
> +	stat->migrate_type = migrate_type;
> +
> +	stat->nr_alloc++;
> +	stat->alloc_bytes += bytes;
>  
>  	order_stats[order][migrate_type]++;
>  
> @@ -455,6 +640,7 @@ static int perf_evsel__process_page_free_event(struct perf_evsel *evsel,
>  	this.page = page;
>  	this.gfp_flags = stat->gfp_flags;
>  	this.migrate_type = stat->migrate_type;
> +	this.callsite = stat->callsite;
>  
>  	rb_erase(&stat->node, &page_tree);
>  	free(stat);
> @@ -466,6 +652,13 @@ static int perf_evsel__process_page_free_event(struct perf_evsel *evsel,
>  	stat->nr_free++;
>  	stat->free_bytes += bytes;
>  
> +	stat = search_page_caller_stat(this.callsite, false);
> +	if (stat == NULL)
> +		return -ENOENT;
> +
> +	stat->nr_free++;
> +	stat->free_bytes += bytes;
> +
>  	return 0;
>  }
>  
> @@ -576,41 +769,89 @@ static const char * const migrate_type_str[] = {
>  	"UNKNOWN",
>  };
>  
> -static void __print_page_result(struct rb_root *root,
> -				struct perf_session *session __maybe_unused,
> -				int n_lines)
> +static void __print_page_alloc_result(struct perf_session *session, int n_lines)
>  {
> -	struct rb_node *next = rb_first(root);
> +	struct rb_node *next = rb_first(&page_alloc_sorted);
> +	struct machine *machine = &session->machines.host;
>  	const char *format;
>  
> -	printf("\n%.80s\n", graph_dotted_line);
> -	printf(" %-16s | Total alloc (KB) | Hits      | Order | Mig.type | GFP flags\n",
> +	printf("\n%.105s\n", graph_dotted_line);
> +	printf(" %-16s | Total alloc (KB) | Hits      | Order | Mig.type | GFP flags | Callsite\n",
>  	       use_pfn ? "PFN" : "Page");
> -	printf("%.80s\n", graph_dotted_line);
> +	printf("%.105s\n", graph_dotted_line);
>  
>  	if (use_pfn)
> -		format = " %16llu | %'16llu | %'9d | %5d | %8s |  %08lx\n";
> +		format = " %16llu | %'16llu | %'9d | %5d | %8s |  %08lx | %s\n";
>  	else
> -		format = " %016llx | %'16llu | %'9d | %5d | %8s |  %08lx\n";
> +		format = " %016llx | %'16llu | %'9d | %5d | %8s |  %08lx | %s\n";
>  
>  	while (next && n_lines--) {
>  		struct page_stat *data;
> +		struct symbol *sym;
> +		struct map *map;
> +		char buf[32];
> +		char *caller = buf;
>  
>  		data = rb_entry(next, struct page_stat, node);
> +		sym = machine__find_kernel_function(machine, data->callsite,
> +						    &map, NULL);
> +		if (sym && sym->name)
> +			caller = sym->name;
> +		else
> +			scnprintf(buf, sizeof(buf), "%"PRIx64, data->callsite);
>  
>  		printf(format, (unsigned long long)data->page,
>  		       (unsigned long long)data->alloc_bytes / 1024,
>  		       data->nr_alloc, data->order,
>  		       migrate_type_str[data->migrate_type],
> -		       (unsigned long)data->gfp_flags);
> +		       (unsigned long)data->gfp_flags, caller);
> +
> +		next = rb_next(next);
> +	}
> +
> +	if (n_lines == -1)
> +		printf(" ...              | ...              | ...       | ...   | ...      | ...       | ...\n");
> +
> +	printf("%.105s\n", graph_dotted_line);
> +}
> +
> +static void __print_page_caller_result(struct perf_session *session, int n_lines)
> +{
> +	struct rb_node *next = rb_first(&page_caller_sorted);
> +	struct machine *machine = &session->machines.host;
> +
> +	printf("\n%.105s\n", graph_dotted_line);
> +	printf(" Total alloc (KB) | Hits      | Order | Mig.type | GFP flags | Callsite\n");
> +	printf("%.105s\n", graph_dotted_line);
> +
> +	while (next && n_lines--) {
> +		struct page_stat *data;
> +		struct symbol *sym;
> +		struct map *map;
> +		char buf[32];
> +		char *caller = buf;
> +
> +		data = rb_entry(next, struct page_stat, node);
> +		sym = machine__find_kernel_function(machine, data->callsite,
> +						    &map, NULL);
> +		if (sym && sym->name)
> +			caller = sym->name;
> +		else
> +			scnprintf(buf, sizeof(buf), "%"PRIx64, data->callsite);
> +
> +		printf(" %'16llu | %'9d | %5d | %8s |  %08lx | %s\n",
> +		       (unsigned long long)data->alloc_bytes / 1024,
> +		       data->nr_alloc, data->order,
> +		       migrate_type_str[data->migrate_type],
> +		       (unsigned long)data->gfp_flags, caller);
>  
>  		next = rb_next(next);
>  	}
>  
>  	if (n_lines == -1)
> -		printf(" ...              | ...              | ...       | ...   | ...      | ...     \n");
> +		printf(" ...              | ...       | ...   | ...      | ...       | ...\n");
>  
> -	printf("%.80s\n", graph_dotted_line);
> +	printf("%.105s\n", graph_dotted_line);
>  }
>  
>  static void print_slab_summary(void)
> @@ -682,8 +923,10 @@ static void print_slab_result(struct perf_session *session)
>  
>  static void print_page_result(struct perf_session *session)
>  {
> +	if (caller_flag)
> +		__print_page_caller_result(session, caller_lines);
>  	if (alloc_flag)
> -		__print_page_result(&page_alloc_sorted, session, alloc_lines);
> +		__print_page_alloc_result(session, alloc_lines);
>  	print_page_summary();
>  }
>  
> @@ -802,6 +1045,7 @@ static void sort_result(void)
>  	}
>  	if (kmem_page) {
>  		__sort_page_result(&page_alloc_tree, &page_alloc_sorted);
> +		__sort_page_result(&page_caller_tree, &page_caller_sorted);
>  	}
>  }
>  
> @@ -1084,7 +1328,7 @@ static int __cmd_record(int argc, const char **argv)
>  	if (kmem_slab)
>  		rec_argc += ARRAY_SIZE(slab_events);
>  	if (kmem_page)
> -		rec_argc += ARRAY_SIZE(page_events);
> +		rec_argc += ARRAY_SIZE(page_events) + 1; /* for -g */
>  
>  	rec_argv = calloc(rec_argc + 1, sizeof(char *));
>  
> @@ -1099,6 +1343,8 @@ static int __cmd_record(int argc, const char **argv)
>  			rec_argv[i] = strdup(slab_events[j]);
>  	}
>  	if (kmem_page) {
> +		rec_argv[i++] = strdup("-g");
> +
>  		for (j = 0; j < ARRAY_SIZE(page_events); j++, i++)
>  			rec_argv[i] = strdup(page_events[j]);
>  	}
> @@ -1159,7 +1405,7 @@ int cmd_kmem(int argc, const char **argv, const char *prefix __maybe_unused)
>  
>  	file.path = input_name;
>  
> -	session = perf_session__new(&file, false, &perf_kmem);
> +	kmem_session = session = perf_session__new(&file, false, &perf_kmem);
>  	if (session == NULL)
>  		return -1;
>  
> @@ -1172,6 +1418,7 @@ int cmd_kmem(int argc, const char **argv, const char *prefix __maybe_unused)
>  		}
>  
>  		kmem_page_size = pevent_get_page_size(evsel->tp_format->pevent);
> +		symbol_conf.use_callchain = true;
>  	}
>  
>  	symbol__init(&session->header.env);
> -- 
> 2.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
